const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// Define a porta do aplicativo
const APP_PORT = 4000; 

// Mapa para rastrear serviços registrados
// Map<string, { url: string, checkpoint: number, status: 'online' | 'offline' }>
const subscribers = new Map(); 

// Número máximo de tentativas para cada evento individual antes de considerar o serviço offline
const MAX_FAILURES = 3; 

// Tempo de espera entre retries (em milissegundos)
const RETRY_DELAY_MS = 200; 

// Backlog de eventos gerados
let eventCounter = 0; 
const baseEventos = {
    events: []
};

// Função auxiliar para atrasar a execução
const delay = ms => new Promise(res => setTimeout(res, ms));

// Endpoint para registro de serviços
app.post('/register', async (req, res) => {

    // Verifica se o corpo da requisição contém serviceId e url
    const { serviceId, url } = req.body; 

    // Verifica se serviceId e url foram fornecidos
    if (!serviceId) return res.status(400).send({ status: '❌ Erro: serviceId é obrigatório para registro!' });
    if (!url) return res.status(400).send({ status: '❌ Erro: url é obrigatória para registro!' });

    // Verifica se o serviceId já está registrado
    let subscriber = subscribers.get(serviceId);

    if (subscriber) {

        // Serviço já existe, verifica se a URL mudou e atualiza
        if (subscriber.url !== url) {
            console.log(`🔁 Serviço '${serviceId}' re-registrou com nova URL: ${url} (anterior: ${subscriber.url})`);
            subscriber.url = url; 
        }

        // Define o status como 'online' se o serviço se registrou novamente
        subscriber.status = 'online';
        console.log(`🟢 Serviço '${serviceId}' re-registrado e status atualizado para 'online'.`);
    
    } else {

        // Novo serviço
        subscriber = {
            url: url,
            checkpoint: -1, // Padrão: começa em -1 para pegar todos os eventos (ID 0 em diante)
            status: 'online' // Novo serviço começa como 'online'
        };

        // Adiciona o novo serviço ao mapa de assinantes
        subscribers.set(serviceId, subscriber);
        console.log(`🧾 Novo serviço registrado: '${serviceId}' com URL: ${url} e status 'online'.`);

    }   

    // Lógica de event-checkpoint
    // Envia todos os eventos que o serviço ainda não recebeu
    // Caso seja um novo serviço, envia todos os eventos (checkpoint -1)
    // Caso seja um serviço re-registrado, envia eventos a partir do checkpoint 
    // Garante a ordem SEQUENCIAL dos eventos do backlog por ID
    const eventsToSend = baseEventos.events.filter(event => event.id > subscriber.checkpoint).sort((a, b) => a.id - b.id);

    if (eventsToSend.length > 0) {

        console.log(`⌯⌲ Enviando ${eventsToSend.length} eventos do backlog para serviço '${serviceId}' (${subscriber.url}) a partir do checkpoint ${subscriber.checkpoint}...`);
        
        let allBacklogSent = true;

        for (const event of eventsToSend) { // Loop for...of para garantir a ordem sequencial

            let eventSentSuccessfully = false;

            for (let i = 0; i < MAX_FAILURES; i++) { // Usa MAX_FAILURES como limite de tentativas por evento
                try {
                    await axios.post(subscriber.url, event);
                    console.log(`  ✅ Evento '${event.type}' (ID: ${event.id}) do backlog enviado para '${serviceId}' (Tentativa: ${i + 1})`);
                    subscriber.checkpoint = event.id; // Atualiza o checkpoint imediatamente após o sucesso
                    eventSentSuccessfully = true;
                    break; // Sai do loop de retries para este evento
                } catch (err) {
                    console.error(`  ❌ Falha na tentativa ${i + 1} ao enviar evento '${event.type}' (ID: ${event.id}) do backlog para '${serviceId}' (${subscriber.url}): ${err.message}`);
                    if (i < MAX_FAILURES - 1) { // Se não for a última tentativa
                        await delay(RETRY_DELAY_MS); // Espera antes de tentar novamente
                    }
                }
            }

            if (!eventSentSuccessfully) {

                console.error(`💀 Todas as ${MAX_FAILURES} tentativas falharam para o evento '${event.type}' (ID: ${event.id}) do backlog para '${serviceId}'.`);
                // Se um evento falhar após todas as tentativas, o serviço é considerado offline
                subscriber.status = 'offline'; 
                console.warn(`🔴 Serviço '${serviceId}' (${subscriber.url}) passou para 'offline' após falhas consecutivas ao enviar backlog.`);
                allBacklogSent = false; // Nem todos os eventos do backlog foram enviados
                break; // Interrompe o envio do backlog, pois a consistência está comprometida
            
            }

        }

        if (allBacklogSent) res.send({ status: `Registrado com sucesso e ${eventsToSend.length} eventos do backlog enviados!` });
        else res.status(500).send({ status: `Registrado, mas falha ao enviar todos os eventos do backlog. Serviço '${serviceId}' offline.` });

    } else {

        // Se não houver eventos no backlog para enviar
        console.log(`⏱ Nenhum evento no backlog para serviço '${serviceId}' (${subscriber.url}) a partir do checkpoint ${subscriber.checkpoint}.`);
        res.send({ status: 'Registrado com sucesso!' });

    }

});

// Endpoint para receber eventos e redistribuir
app.post('/events', async (req, res) => {

    // Verifica se o corpo da requisição contém um evento válido
    const event = req.body;
    if (!event || !event.type || !event.payload) {
        return res.status(400).send({ status: 'Erro: Evento inválido!' });
    }

    // Cria um novo evento com um ID único
    const newEvent = {
        id: eventCounter++,
        type: event.type,
        payload: event.payload
    };

    // Adiciona o evento à lista de eventos
    baseEventos.events.push(newEvent);

    // Log do evento recebido
    console.log(`Evento recebido (ID: ${newEvent.id}): ${newEvent.type}`);

    // Envia o evento para todos os serviços registrados que estão 'online'
    const deliveryPromises = Array.from(subscribers.entries())
        .filter(([, sub]) => sub.status === 'online') // Filtra apenas os assinantes 'online'
        .map(async ([serviceId, subscriber]) => {

            let eventDelivered = false;

            for (let i = 0; i < MAX_FAILURES; i++) { // Usa MAX_FAILURES como limite de tentativas

                try {

                    await axios.post(subscriber.url, newEvent);
                    console.log(`⌯⌲ Evento '${newEvent.type}' (ID: ${newEvent.id}) enviado para '${serviceId}' (Tentativa: ${i + 1}).`);
                    subscriber.checkpoint = newEvent.id; // Atualiza o checkpoint após o envio bem-sucedido
                    eventDelivered = true;
                    break; // Sai do loop de retries

                } catch (err) {

                    console.error(`❌ Falha na tentativa ${i + 1} ao enviar para '${serviceId}' (${subscriber.url}): ${err.message}`);

                    if (i < MAX_FAILURES - 1) { // Se não for a última tentativa
                        await delay(RETRY_DELAY_MS); // Espera antes de tentar novamente
                    }

                }

            }

            if (!eventDelivered) {

                // Se todas as tentativas falharem
                console.error(`❌ Todas as ${MAX_FAILURES} tentativas falharam para o evento '${newEvent.type}' (ID: ${newEvent.id}) para '${serviceId}'.`);
                // Se o número de falhas atingir o limite, altera o status para 'offline'
                subscriber.status = 'offline';
                console.warn(`🔴 Serviço '${serviceId}' (${subscriber.url}) passou para 'offline' após ${MAX_FAILURES} falhas consecutivas.`);

            }

        });

    await Promise.all(deliveryPromises);
    res.send({ status: 'Evento processado!' });

});

// Endpoint para listar os assinantes (agora com status)
app.get('/subscribers', (_, res) => {
    res.send(Array.from(subscribers.entries()).map(([serviceId, data]) => ({ serviceId, ...data })));
});

// Endpoint para listar todos os eventos
app.get('/events', (_, res) => {
    res.send(baseEventos);
});

// Inicia o servidor
app.listen(APP_PORT, () => console.log(`🟢 EVENT-BUS (${APP_PORT}): [OK]`));

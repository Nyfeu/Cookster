const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// Lista de serviços registrados para receber eventos
const subscribers = new Set();

// Mapa para rastrear falhas de envio de eventos
const failures = new Map();
const MAX_FAILURES = 3;

// Lista de eventos gerados
const baseEventos = {
    events: []
};

// Enumeração de eventos
const EventType = {}

// Endpoint para registro de serviços
app.post('/register', (req, res) => {

    const { url } = req.body;

    if (!subscribers.has(url)) {

        // Registra o serviço se não estiver na lista
        subscribers.add(url);

        // Inicializa contagem de falhas
        failures.set(url, 0);

        // Log do registro
        console.log(`Serviço registrado: ${url}`);

        // Envia uma resposta de sucesso
        res.send({ status: 'Registrado com sucesso!' });

    } else {

        res.send({ status: 'Já registrado!' });

    }

});

// Endpoint para receber eventos e redistribuir
app.post('/events', async (req, res) => {

    // Verifica se o corpo da requisição contém um evento
    const event = req.body;

    // Adiciona o evento à lista de eventos
    baseEventos.events.push(event);

    // Log do evento recebido
    console.log('Evento recebido:', event.type);

    // Envia o evento para todos os serviços registrados
    const promises = Array.from(subscribers).map(url =>
        axios.post(url, event).catch(err => {

            // Log de erro ao enviar o evento
            console.error(`Falha ao enviar para ${url}`);

            // Incrementa a contagem de falhas
            const currentFailures = failures.get(url) || 0;

            // Atualiza o mapa de falhas
            failures.set(url, currentFailures + 1);

            // Se o número de falhas atingir o limite, remove o serviço
            if (currentFailures + 1 >= MAX_FAILURES) {
                console.warn(`Removendo serviço ${url} após ${MAX_FAILURES} falhas consecutivas.`);
                subscribers.delete(url);
                failures.delete(url);
            }

        })
    );

    await Promise.all(promises);
    res.send({ status: 'Evento processado!' });

});

app.get('/subscribers', (_, res) => {

    // Retorna a lista de serviços registrados
    res.send(Array.from(subscribers));

});

app.get('/events', (_, res) => {

    // Retorna a lista de eventos gerados
    res.send(baseEventos);

});

app.listen(4000, () => {
    console.log('Event Bus (4000): [OK]');
});
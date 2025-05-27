const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// Lista de serviços registrados para receber eventos
const subscribers = [];

// Mapa para rastrear falhas de envio de eventos
const failures = new Map();
const MAX_FAILURES = 3;

// Endpoint para registro de serviços
app.post('/register', (req, res) => {

    const { url } = req.body;

    if (!subscribers.includes(url)) {

        // Registra o serviço se não estiver na lista
        subscribers.add(url);

        // Inicializa contagem de falhas
        failures.set(url, 0);

        // Log do registro
        console.log(`Serviço registrado: ${url}`);

    }

    res.send({ status: 'Registrado com sucesso!' });

});

// Endpoint para receber eventos e redistribuir
app.post('/events', async (req, res) => {

    const event = req.body;

    // Log do evento recebido
    console.log('Evento recebido:', event.type);

    // Envia o evento para todos os serviços registrados
    const promises = subscribers.map(url =>
        axios.post(url, event).catch(err => {

            // Log de erro ao enviar o evento
            console.error(`Falha ao enviar para ${url}:`, err.message);

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

app.listen(4000, () => {
    console.log('Barramento de eventos ouvindo na porta 4000');
});
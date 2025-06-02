const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const axios = require('axios');

// Esquemas de dados do MongoDB
const Recipe = require('./models/Recipe');

// Lendo dados .env
require('dotenv').config();

// Configurando o Middleware
const app = express();
app.use(express.json());

// Configurações
const APP_PORT = 5000;
const EVENT_BUS_PORT = 4000;

// CORS
app.use(cors({
    origin: 'http://localhost:5173',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));

// Conexão com MongoDB
const dbUser = process.env.DB_USER;
const dbPassword = process.env.DB_PASS;
const mongoURI = `mongodb+srv://${dbUser}:${dbPassword}@cluster0.fbrwz1j.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0`;

mongoose.connect(mongoURI)
    .then(() => {

        console.log('✅ Conectado ao MongoDB');

        app.listen(APP_PORT, async () => {
            console.log(`🟢 MSS-RECIPE (http://localhost:${APP_PORT}): [OK]`);

            try {

                await axios.post(`http://localhost:${EVENT_BUS_PORT}/register`, {
                    url: `http://localhost:${APP_PORT}`
                });

                console.log('📡 Registrado no Event Bus com sucesso');

            } catch (error) {

                console.error('❌ Falha ao registrar no Event Bus:', error.message);

            }

        });

    }).catch(err => {

        console.error('❌ Erro ao conectar ao MongoDB:', err);

    });

// Endpoint para consultar receitas
app.get('/recipes', async (req, res) => {

    try {

        const { user_id, name } = req.query;

        // Filtro dinâmico
        const filter = {};
        if (user_id) filter.user_id = user_id;
        if (name) filter.name = { $regex: name, $options: 'i' }; // busca parcial, case-insensitive

        console.log('🔍 Filtro:', filter);  // DEBUG

        const recipes = await Recipe.find(filter);

        console.log('📄 Receitas encontradas:', recipes); // DEBUG

        res.status(200).json(recipes);

    } catch (err) {

        console.error('❌ Erro ao buscar receitas:', err);
        res.status(500).json({ error: 'Erro ao buscar receitas.' });

    }

});


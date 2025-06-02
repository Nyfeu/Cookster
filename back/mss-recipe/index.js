const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const axios = require('axios');

// Esquemas de dados do MongoDB
const Recipe = require('./models/Recipe');
const Pantry = require('./models/Pantry');

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

        const { user_id, name, ingredients } = req.query;

        // Filtro dinâmico
        const matchStage = {};

        if (user_id) matchStage.user_id = user_id;
        if (name) matchStage.name = { $regex: name, $options: 'i' };

        let pipeline = [{ $match: matchStage }];

        if (ingredients) {
            const ingredientList = ingredients
                .split(',')
                .map(i => i.trim().toLowerCase());

            pipeline.push(
                {
                    $addFields: {
                        ingredient_names: {
                            $map: {
                                input: "$ingredients",
                                as: "ing",
                                in: "$$ing.name"
                            }
                        }
                    }
                },
                {
                    $match: {
                        $expr: {
                            $setIsSubset: ["$ingredient_names", ingredientList]
                        }
                    }
                },
                {
                    $project: {
                        ingredient_names: 0 // remove campo auxiliar
                    }
                }
            );
        }

        const recipes = await Recipe.aggregate(pipeline);

        res.status(200).json(recipes);

    } catch (err) {

        console.error('❌ Erro ao buscar receitas:', err);
        res.status(500).json({ error: 'Erro ao buscar receitas.' });

    }

});

app.get('/suggest', async (req, res) => {

  try {
    
    const { user_id, name } = req.query;

    if (!user_id) {
      return res.status(400).json({ error: "user_id é obrigatório." });
    }

    // Busca a pantry do usuário
    const pantry = await Pantry.findOne({ userId: user_id });

    if (!pantry || pantry.ingredientes.length === 0) {
      return res.status(404).json({ error: "Nenhum ingrediente encontrado na despensa do usuário." });
    }

    // Extrai nomes dos ingredientes (em minúsculas)
    const ingredientList = pantry.ingredientes.map(ing => ing.nome.toLowerCase());

    // Construção do pipeline
    const matchStage = {};
    if (name) matchStage.name = { $regex: name, $options: 'i' };

    const pipeline = [
      { $match: matchStage },
      {
        $addFields: {
          ingredient_names: {
            $map: {
              input: "$ingredients",
              as: "ing",
              in: { $toLower: "$$ing.name" }
            }
          }
        }
      },
      {
        $match: {
          $expr: {
            $setIsSubset: ["$ingredient_names", ingredientList]
          }
        }
      },
      {
        $project: {
          ingredient_names: 0 // remove campo auxiliar
        }
      }
    ];

    const recipes = await Recipe.aggregate(pipeline);

    res.status(200).json(recipes);

  } catch (err) {
    console.error('❌ Erro ao buscar receitas:', err);
    res.status(500).json({ error: 'Erro ao buscar receitas.' });
  }

});

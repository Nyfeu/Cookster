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
const SERVICE_ID = 'mss-recipe';
const APP_PORT = 9000;
const EVENT_BUS_URL = 'http://localhost:4000';

// CORS
app.use(cors({
    origin: 'http://localhost:5173',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));

// Conexão com MongoDB
const dbUser = process.env.DB_USER;
const dbPassword = process.env.DB_PASS;
const mongoURI = `mongodb+srv://${dbUser}:${dbPassword}@cluster0.fbrwz1j.mongodb.net/mss-recipe?retryWrites=true&w=majority&appName=Cluster0`;

// Função para aplicar paginação
const applyPagination = (pipeline, req) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    pipeline.push({ $skip: skip }, { $limit: limit });
    return pipeline;
};

// Conexão com o MongoDB e inicialização do servidor
mongoose.connect(mongoURI)
    .then(() => {

        console.log('✅ MongoDB: [OK]');

        app.listen(APP_PORT, async () => {
            console.log(`🟢 MSS-RECIPE (${APP_PORT}): [OK]`);

            try {

                await axios.post(`${EVENT_BUS_URL}/register`, {
                    serviceId: SERVICE_ID,
                    url: `http://localhost:${APP_PORT}/events` 
                });

                console.log('📡 EVENT-BUS: [REGISTERED]');

            } catch (error) {

                console.error('❌ EVENT-BUS: [FAILED]');

            }

        });

    }).catch(_ => console.error('❌ MongoDB: [FAILED]'));

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

        // Paginação
        applyPagination(pipeline, req);

        // Consulta ao banco de dados
        const recipes = await Recipe.aggregate(pipeline);

        // Retorna as receitas encontradas
        res.status(200).json(recipes);

    } catch (err) {

        // Em caso de erro, loga o erro e retorna uma mensagem de erro
        console.error('❌ Erro ao buscar receitas:', err);
        res.status(500).json({ error: 'Erro ao buscar receitas.' });

    }

});

// Endpoint para consultar uma receita específica
app.get('/recipes/:id', async (req, res) => {
    try {
        const { id } = req.params; 
        const recipe = await Recipe.findById(id); 

        if (!recipe) {
            return res.status(404).json({ error: 'Receita não encontrada.' }); 
        }

        res.status(200).json(recipe); 

    } catch (err) {
        console.error('❌ Erro ao buscar receita por ID:', err);
        res.status(500).json({ error: 'Erro ao buscar receita.' }); 
    }
});

// Endpoint para sugerir receitas com base na despensa do usuário
app.get('/suggest', async (req, res) => {

    try {

        const user_id = req.headers['user_id'];

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
        const pipeline = [
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

        // Paginação
        applyPagination(pipeline, req);

        // Consulta ao banco de dados
        const recipes = await Recipe.aggregate(pipeline);

        // Retorna as receitas encontradas
        res.status(200).json(recipes);

    } catch (err) {

        // Em caso de erro, loga o erro e retorna uma mensagem de erro
        console.error('❌ Erro ao buscar receitas:', err);
        res.status(500).json({ error: 'Erro ao buscar receitas.' });

    }

});

// Endpoint para receber eventos do Event Bus
app.post('/events', async (req, res) => {

    const { type, payload } = req.body; // 'type' e 'payload' virão do Event Bus

    console.log(`Evento recebido: ${type}`);

    try {
        
        switch (type) {

            case 'IngredientAdded':

                console.log('Processando evento IngredientAdded:', payload);

                // Espera-se que 'payload' contenha: { userId, ingredient: { nome, categoria } }
                const { userId: addedUserId, ingredient: addedIngredient } = payload;

                let pantryToAdd = await Pantry.findOne({ userId: addedUserId });

                if (pantryToAdd) {

                    // Verifica se o ingrediente já existe para o usuário de forma case-insensitive
                    const ingredientExists = pantryToAdd.ingredientes.some(
                        (ing) => ing.nome.toLowerCase() === addedIngredient.nome.toLowerCase()
                    );

                    if (!ingredientExists) {

                        pantryToAdd.ingredientes.push(addedIngredient);
                        console.log(`Ingrediente '${addedIngredient.nome}' adicionado à despensa do usuário ${addedUserId}.`);

                    } else {

                        console.log(`Ingrediente '${addedIngredient.nome}' já existe para o usuário ${addedUserId}. Pulando adição.`);

                    }

                } else {

                    // Cria uma nova despensa para o usuário se não existir
                    pantryToAdd = new Pantry({
                        userId: addedUserId,
                        ingredientes: [addedIngredient]
                    });

                    console.log(`Nova despensa criada para o usuário ${addedUserId} com o ingrediente '${addedIngredient.nome}'.`);

                }

                // Salva a despensa atualizada
                await pantryToAdd.save();
                break;

            case 'IngredientRemoved':

                console.log('Processando evento IngredientRemoved:', payload);

                // Espera-se que 'payload' contenha: { userId, ingredient: { nome, categoria } }
                const { userId: removedUserId, ingredient: removedIngredient } = payload;

                let pantryToRemove = await Pantry.findOne({ userId: removedUserId });

                if (pantryToRemove) {

                    // Filtra o ingrediente a ser removido (case-insensitive)
                    const initialLength = pantryToRemove.ingredientes.length;
                    pantryToRemove.ingredientes = pantryToRemove.ingredientes.filter(
                        (ing) => ing.nome.toLowerCase() !== removedIngredient.nome.toLowerCase()
                    );

                    if (pantryToRemove.ingredientes.length < initialLength) {

                        await pantryToRemove.save();
                        console.log(`Ingrediente '${removedIngredient.nome}' removido da despensa do usuário ${removedUserId}.`);

                    } else {

                        console.warn(`Ingrediente '${removedIngredient.nome}' não encontrado na despensa do usuário ${removedUserId} para remoção.`);

                    }

                } else {

                    console.warn(`Despensa não encontrada para o usuário ${removedUserId} para remoção de ingrediente.`);

                }

                break;

            default:

                // Se o tipo de evento não for reconhecido, loga um aviso
                console.warn(`Tipo de evento desconhecido: ${type}`);

        }

        res.status(200).send('Evento processado com sucesso');

    } catch (error) {

        // Em caso de erro, loga o erro e retorna uma mensagem de erro
        console.error('❌ Erro ao processar evento:', error.message);
        res.status(500).send('Erro interno do servidor ao processar evento.');

    }

});

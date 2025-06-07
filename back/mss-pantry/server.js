if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config()
}

// Importar dependências
const axios = require('axios')
const express = require('express')
const mongoose = require('mongoose')
const cors = require('cors')
const Ingredient = require('./models/Ingredient')

const app = express()

const dbUser = process.env.DB_USER
const dbPass = process.env.DB_PASS

// Configurações
const APP_PORT = process.env.SERVICE_PORT || 3001;
const SERVICE_ID = 'mss-pantry';
const EVENT_BUS_URL = process.env.EVENT_BUS_URL || 'http://localhost:4000';
const SERVICE_URL = process.env.SERVICE_URL || 'http://localhost';
const SERVICE_FULL_URL = SERVICE_URL + ':' + APP_PORT;

// Configuração do MongoDB
const mongoURI = `mongodb+srv://${dbUser}:${dbPass}@cluster0.fbrwz1j.mongodb.net/mss-pantry?retryWrites=true&w=majority&appName=Cluster0`

// Middleware para permitir requisições do frontend
app.use(cors({
  origin: 'http://localhost:5173',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}))

app.use(express.json())

// Rotas CRUD

// Listar todos ingredientes do usuário
app.get('/ingredients', async (req, res) => {
  try {
    const userId = req.headers['user-id'];
    const pantry = await Ingredient.findOne({ userId })

    if (!pantry) return res.json([])

    res.json(pantry.ingredientes)
  } catch (err) {
    res.status(500).json({ error: 'Erro ao buscar ingredientes' })
  }
})


// Criar ingrediente
app.post('/ingredients', async (req, res) => {

  try {

    const userId = req.headers['user-id'];

    const { nome, categoria } = req.body

    if (!nome || !categoria) {
      return res.status(400).json({ error: 'Nome e categoria são obrigatórios' })
    }

    let pantry = await Ingredient.findOne({ userId })

    if (!pantry) {
      pantry = new Ingredient({ userId, ingredientes: [] })
    }

    // Verifica duplicata
    const existe = pantry.ingredientes.some(
      ing => ing.nome === nome && ing.categoria === categoria
    )

    if (existe) {
      return res.status(409).json({ error: 'Ingrediente já existe' })
    }

    pantry.ingredientes.push({ nome, categoria })
    await pantry.save()

    try {
      await axios.post(`${EVENT_BUS_URL}/events`, {
        type: 'IngredientAdded',
        payload: {
          userId: userId,
          ingredient: {
            nome,
            categoria
          }
        }
      });
      console.log(`Evento IngredientAdded emitido para o Event Bus: ${nome} (${categoria}) para o usuário ${userId}`);
    } catch (eventBusErr) {
      console.error('Falha ao emitir evento IngredientAdded para o Event Bus:', eventBusErr.message);
    }

    res.status(201).json(pantry.ingredientes)

  } catch (err) {

    res.status(500).json({ error: 'Erro ao adicionar ingrediente' })

  }

})




// Atualizar ingrediente pelo ID
app.put('/ingredients/:index', async (req, res) => {
  try {
    const userId = req.headers['user-id'];
    const index = parseInt(req.params.index, 10)
    const updates = req.body

    const pantry = await Ingredient.findOne({ userId })
    if (!pantry || !pantry.ingredientes[index]) {
      return res.status(404).json({ error: 'Ingrediente não encontrado' })
    }

    Object.assign(pantry.ingredientes[index], updates)
    await pantry.save()

    res.json(pantry.ingredientes[index])
  } catch (err) {
    res.status(500).json({ error: 'Erro ao atualizar ingrediente' })
  }
})


// Deletar ingrediente pelo Nome (Categoria opcional)
app.delete('/ingredients', async (req, res) => {
  try {
    const userId = req.headers['user-id'];
    const { nome, categoria } = req.body

    if (!nome) {
      return res.status(400).json({ error: 'Nome do ingrediente é obrigatório' })
    }

    const pantry = await Ingredient.findOne({ userId })
    if (!pantry) {
      return res.status(404).json({ error: 'Pantry não encontrada para este usuário' })
    }

    // Se categoria for informada, filtra por nome + categoria. Senão, só por nome.
    const index = pantry.ingredientes.findIndex(ing =>
      ing.nome === nome && (!categoria || ing.categoria === categoria)
    )

    if (index === -1) {
      return res.status(404).json({ error: 'Ingrediente não encontrado' })
    }

    const ingredienteRemovido = pantry.ingredientes.splice(index, 1)[0]
    await pantry.save()

    try {
      await axios.post(`${EVENT_BUS_URL}/events`, {
        type: 'IngredientRemoved',
        payload: {
          userId: userId,
          ingredient: {
            nome: ingredienteRemovido.nome,
            categoria: ingredienteRemovido.categoria
          }
        }
      });
      console.log(`Evento IngredientRemoved emitido para o Event Bus: ${ingredienteRemovido.nome} (${ingredienteRemovido.categoria}) para o usuário ${userId}`);
    } catch (eventBusErr) {
      console.error('Falha ao emitir evento IngredientRemoved para o Event Bus:', eventBusErr.message);
    }

    res.json({
      message: 'Ingrediente removido com sucesso',
      ingrediente: ingredienteRemovido
    })
  } catch (err) {
    res.status(500).json({ error: 'Erro ao deletar ingrediente' })
  }
})


//lista - filter - montar lista nova sem o ingrediente

// Teste simples
app.get('/', (req, res) => {
  res.json({ message: 'Pantry Service está no ar!' })
})


app.post('/events', async (req, res) => {

  const event = req.body;
  console.log('Evento recebido:', event.type);
  res.status(200).send('Evento processado ou reconhecido');

})
// Conexão com banco e start do servidor

mongoose.connect(mongoURI)
  .then(() => {

    console.log('✅ MongoDB: [OK]');

    app.listen(APP_PORT, async () => {

      console.log(`🟢 PANTRY-SERVICE (${APP_PORT}): [OK]`);

      try {

        await axios.post(`${EVENT_BUS_URL}/register`, {
          serviceId: SERVICE_ID,
          url: `${SERVICE_FULL_URL}/events`
        });

        console.log('📡 EVENT-BUS: [REGISTERED]');

      } catch (error) {

        console.error('❌ EVENT-BUS: [FAILED]');

      }

    });

  }).catch(_ => console.error('❌ MongoDB: [FAILED]'));
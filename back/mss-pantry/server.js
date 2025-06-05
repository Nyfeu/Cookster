if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config()
}

const axios = require('axios')
const express = require('express')
const mongoose = require('mongoose')
const jwt = require('jsonwebtoken')
const cors = require('cors')
const Ingredient = require('./models/Ingredient')

const app = express()

const dbUser = process.env.DB_USER
const dbPass = process.env.DB_PASS
const jwtSecret = process.env.JWT_SECRET
const APP_PORT = 3001
const EVENT_BUS_PORT = 4000
const mongoURI = `mongodb+srv://${dbUser}:${dbPass}@cluster0.fbrwz1j.mongodb.net/mss-pantry?retryWrites=true&w=majority&appName=Cluster0`

// Middleware para permitir requisições do frontend
app.use(cors({
  origin: 'http://localhost:5173',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}))

app.use(express.json())

// Middleware para checar autenticação via JWT
function checkAuthenticated(req, res, next) {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token não fornecido' })
  }

  const token = authHeader.split(' ')[1]

  try {
    const decoded = jwt.verify(token, jwtSecret)
    req.user = decoded
    next()
  } catch (err) {
    return res.status(403).json({ error: 'Token inválido ou expirado' })
  }
}

// Rotas CRUD

// Listar todos ingredientes do usuário
app.get('/ingredients', checkAuthenticated, async (req, res) => {
  try {
    const userId = req.user.id
    const pantry = await Ingredient.findOne({ userId })

    if (!pantry) return res.json([])

    res.json(pantry.ingredientes)
  } catch (err) {
    res.status(500).json({ error: 'Erro ao buscar ingredientes' })
  }
})


// Criar ingrediente
app.post('/ingredients', checkAuthenticated, async (req, res) => {
  try {
    const userId = req.user.id
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
        await axios.post(`http://localhost:${EVENT_BUS_PORT}/events`, {
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
app.put('/ingredients/:index', checkAuthenticated, async (req, res) => {
  try {
    const userId = req.user.id
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
app.delete('/ingredients', checkAuthenticated, async (req, res) => {
  try {
    const userId = req.user.id
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
        await axios.post(`http://localhost:${EVENT_BUS_PORT}/events`, {
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
})

// Conexão com banco e start do servidor

mongoose.connect(mongoURI)
    .then(() => {

        console.log('✅ Conectado ao MongoDB');

        app.listen(APP_PORT, async () => {
            console.log(`🟢 PANTRY-SERVICE (http://localhost:${APP_PORT}): [OK]`);

            try {

                await axios.post(`http://localhost:${EVENT_BUS_PORT}/register`, {
                    url: `http://localhost:${APP_PORT}/events`
                });

                console.log('📡 Registrado no Event Bus com sucesso');

            } catch (error) {

                console.error('❌ Falha ao registrar no Event Bus:', error.message);

            }

        });

    }).catch(err => {

        console.error('❌ Erro ao conectar ao MongoDB:', err);

    });
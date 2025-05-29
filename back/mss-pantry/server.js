if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config()
}

const express = require('express')
const mongoose = require('mongoose')
const jwt = require('jsonwebtoken')
const cors = require('cors')
const Ingredient = require('./models/Ingredient')

const app = express()

const dbUser = process.env.DB_USER
const dbPass = process.env.DB_PASS
const jwtSecret = process.env.JWT_SECRET
const port = process.env.PORT || 4000

// Middleware para permitir requisições do frontend
app.use(cors({
  origin: 'http://localhost:5173',  // ajuste conforme seu frontend
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
    const ingredients = await Ingredient.find({ userId })
    res.json(ingredients)
  } catch (err) {
    res.status(500).json({ error: 'Erro ao buscar ingredientes' })
  }
})

// Criar ingrediente
app.post('/ingredients', checkAuthenticated, async (req, res) => {
  try {
    const userId = req.user.id
    const { nome, quantidade, unidade, dataValidade, categoria } = req.body

     if (!nome || !quantidade || !unidade || !dataValidade || !categoria) {
      return res.status(400).json({ error: 'Todos os campos são obrigatórios' })
    }

    const ingredient = new Ingredient({
      userId,
      nome,
      quantidade,
      unidade,
      dataValidade,
      categoria
    })

    await ingredient.save()
    res.status(201).json(ingredient)
  } catch (err) {
    res.status(500).json({ error: 'Erro ao criar ingrediente' })
  }
})

// Atualizar ingrediente pelo ID
app.put('/ingredients/:id', checkAuthenticated, async (req, res) => {
  try {
    const userId = req.user.id
    const ingredientId = req.params.id
    const updates = req.body

    // Só pode atualizar ingrediente do próprio usuário
    const ingredient = await Ingredient.findOne({ _id: ingredientId, userId })

    if (!ingredient) {
      return res.status(404).json({ error: 'Ingrediente não encontrado' })
    }

    Object.assign(ingredient, updates)

    await ingredient.save()
    res.json(ingredient)
  } catch (err) {
    res.status(500).json({ error: 'Erro ao atualizar ingrediente' })
  }
})

// Deletar ingrediente pelo ID
app.delete('/ingredients/:id', checkAuthenticated, async (req, res) => {
  try {
    const userId = req.user.id
    const ingredientId = req.params.id

    const ingredient = await Ingredient.findOneAndDelete({ _id: ingredientId, userId })

    if (!ingredient) {
      return res.status(404).json({ error: 'Ingrediente não encontrado' })
    }

    res.json({ message: 'Ingrediente removido com sucesso' })
  } catch (err) {
    res.status(500).json({ error: 'Erro ao deletar ingrediente' })
  }
})

// Teste simples
app.get('/', (req, res) => {
  res.json({ message: 'Pantry Service está no ar!' })
})

// Conexão com banco e start do servidor
mongoose.connect(`mongodb+srv://${dbUser}:${dbPass}@cluster0.fbrwz1j.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0`)
  .then(() => {
    app.listen(port, () => {
      console.log(`Pantry Service rodando na porta ${port}`)
    })
  })
  .catch(err => {
    console.error('Erro ao conectar no MongoDB', err)
  })
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config()
}

const express = require('express')
const app = express()
const bcrypt = require('bcrypt')
const mongoose = require('mongoose')
const passport = require('passport')
const flash = require('express-flash')
const initializePassport = require('./passport-config')
const jwt = require('jsonwebtoken')
const cors = require('cors')
const User = require('./models/User')

const axios = require('axios')

const port = 3000
const event_bus_port = 4000

// Permitir acesso do front-end
app.use(cors({
  origin: 'http://localhost:5173',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}))

//const users = []

initializePassport(
  passport,
  async email => await User.findOne({ email }),
  async id => await User.findOne({ id})
)

app.use(express.urlencoded({ extended: false }))
app.use(express.json())
app.use(flash())
app.use(passport.initialize())




function checkAuthenticated(req, res, next) {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token não fornecido' })
  }

  const token = authHeader.split(' ')[1]

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next(); // Segue para a próxima função (a rota de "/dashboard", por exemplo)
  } catch (err) {
    return res.status(403).json({ error: 'Token inválido ou expirado' })
  }
}



function checkNotAuthenticated(req, res, next) {
  const authHeader = req.headers.authorization
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return res.status(403).json({ error: 'Você já está autenticado' })
  }
  next()
}

// Rota pública (Landing Page)
app.get('/', (req, res) => {
  res.json({
    message: 'Bem-vindo ao Cookster meu nobre! Acesse sua área privada após o login.'
  })
})

// Rota privada (somente usuários autenticados podem acessar)
app.get('/dashboard', checkAuthenticated, (req, res) => {
  res.json({
    message: 'Você está autenticado e acessou sua página privada.',
    user: req.user
  })
})

app.get('/profile', checkAuthenticated, (req, res) => {
  res.json({
    message: 'Você está autenticado e acessou sua página privada.',
    user: req.user 
  })
})

app.get('/register', (req, res) => {
  res.json(users)
})


// Login local
app.post('/login', checkNotAuthenticated, (req, res, next) => {
  passport.authenticate('local', (err, user, info) => {
    if (err) return next(err)
    if (!user) return res.status(401).json({ error: info.message })

    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' })
    return res.status(200).json({
      message: 'Login bem-sucedido',
      token,
      user: { id: user.id, name: user.name, email: user.email }
    })
  })(req, res, next)
})


// Cadastro
app.post('/register', checkNotAuthenticated, async (req, res) => {
  const { name, email, password } = req.body

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Todos os campos são obrigatórios' })
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(email)) {
    return res.status(400).json({ error: 'Formato de email inválido' })
  }

  const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/
  if (!strongPasswordRegex.test(password)) {
    return res.status(400).json({
      error: 'A senha deve conter ao menos 8 caracteres, uma letra maiúscula, uma minúscula e um número.'
    })
  }

  const existingUser = await User.findOne({ email: email})
  if(existingUser) {
    return res.status(409).json({ error: 'Email já cadastrado' })
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10)

    const user = new User({
      id: Date.now().toString(),
      name,
      email,
      password: hashedPassword
    })

    await user.save()
    
    return res.status(201).json({
      message: 'Usuário cadastrado com sucesso',
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    })
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: 'Erro ao cadastrar usuário' })
  }
})

// Autenticação com Google
app.get('/auth/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
)

app.get('/auth/google/callback',
  passport.authenticate('google', { session: false, failureRedirect: '/login' }),
  (req, res) => {
    const token = jwt.sign(
      { id: req.user.id, email: req.user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    )

    const redirectUrl = `http://localhost:5173/auth-success?token=${token}&name=${encodeURIComponent(req.user.name)}&email=${encodeURIComponent(req.user.email)}`;
    res.redirect(redirectUrl);
  }
)

// Autenticação com Facebook
app.get('/auth/facebook',
  passport.authenticate('facebook', { scope: ['email'] })
)

app.get('/auth/facebook/callback',
  passport.authenticate('facebook', { session: false, failureRedirect: '/login' }),
  (req, res) => {
    const token = jwt.sign(
      { id: req.user.id, email: req.user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    )

    const redirectUrl = `http://localhost:5173/auth-success?token=${token}&name=${encodeURIComponent(req.user.name)}&email=${encodeURIComponent(req.user.email)}`;
    res.redirect(redirectUrl);
  }
)

// "Logout" com JWT (frontend remove o token)
app.delete('/logout', checkAuthenticated, (req, res) => {
  res.status(200).json({ message: 'Logout simbólico com JWT. Basta remover o token no frontend.' })
})

const dbUser = process.env.DB_USER
const dbPassword = process.env.DB_PASS

mongoose.connect(`mongodb+srv://${dbUser}:${dbPassword}@cluster0.fbrwz1j.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0`)
  .then(() => {
    app.listen(3000, () => console.log('Servidor rodando na porta 3000'))
    console.log('Conectado ao MongoDB')
  })
  .catch(err => console.log(err))

app.listen(port, async () => {

  console.log(`mss-autenticacao (localhost:${port}): [OK]`)

  try {
    await axios.post(`http://localhost:${event_bus_port}/register`, { url: `http://localhost:${port}` });
    console.log(`Event Bus Registration (http://localhost:${port}): [OK]`);
  } catch (error) {
    console.error(`Event Bus Registration (http://localhost:${port}): [FAILED]`, error.message);
  }

})
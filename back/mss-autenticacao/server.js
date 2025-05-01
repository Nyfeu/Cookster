if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config()
}

const express = require('express')
const app = express()
const bcrypt = require('bcrypt')
const passport = require('passport')
const flash = require('express-flash')
const initializePassport = require('./passport-config')
const jwt = require('jsonwebtoken')

const users = []

initializePassport(
  passport,
  email => users.find(user => user.email === email),
  id => users.find(user => user.id === id)
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

  const existingUser = users.find(user => user.email === email)
  if (existingUser) {
    return res.status(409).json({ error: 'Email já cadastrado' })
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10)
    const newUser = {
      id: Date.now().toString(),
      name,
      email,
      password: hashedPassword
    }
    users.push(newUser)

    return res.status(201).json({
      message: 'Usuário cadastrado com sucesso',
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email
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
    const token = jwt.sign({ id: req.user.id, email: req.user.email }, process.env.JWT_SECRET, { expiresIn: '1h' })
    res.json({ message: 'Autenticado com sucesso via Google', token, user: req.user })
  }
)

// Autenticação com Facebook
app.get('/auth/facebook',
  passport.authenticate('facebook', { scope: ['email'] })
)

app.get('/auth/facebook/callback',
  passport.authenticate('facebook', { session: false, failureRedirect: '/login' }),
  (req, res) => {
    const token = jwt.sign({ id: req.user.id, email: req.user.email }, process.env.JWT_SECRET, { expiresIn: '1h' })
    res.json({ message: 'Autenticado com sucesso via Facebook', token, user: req.user })
  }
)

// "Logout" com JWT (frontend remove o token)
app.delete('/logout', checkAuthenticated, (req, res) => {
  res.status(200).json({ message: 'Logout simbólico com JWT. Basta remover o token no frontend.' })
})

app.listen(3000, () => console.log('Servidor rodando na porta 3000'))

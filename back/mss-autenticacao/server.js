if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config()
}

// Importar dependências
const express = require('express')
const app = express()
const bcrypt = require('bcrypt')
const mongoose = require('mongoose')
const passport = require('passport')
const flash = require('express-flash')
const initializePassport = require('./passport-config')
const jwt = require('jsonwebtoken')
const cors = require('cors')
const axios = require('axios')

// Importar modelo de usuário
const User = require('./models/User')

// Configurações do banco de dados e variáveis de ambiente
const dbUser = process.env.DB_USER
const dbPass = process.env.DB_PASS

// Configurações do servidor
const APP_PORT = process.env.SERVICE_PORT || 3000;
const SERVICE_ID = 'mss-autenticacao';
const EVENT_BUS_URL = process.env.EVENT_BUS_URL || 'http://localhost:4000';
const SERVICE_URL = process.env.SERVICE_URL || 'http://localhost';
const SERVICE_FULL_URL = SERVICE_URL + ':' + APP_PORT;

// Configuração do MongoDB
const mongoURI = `mongodb+srv://${dbUser}:${dbPass}@cluster0.fbrwz1j.mongodb.net/mss-autenticacao?retryWrites=true&w=majority&appName=Cluster0`

// Permitir acesso do front-end
app.use(cors({
  origin: '*', // <-- A mudança principal: permite qualquer origem
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}))

initializePassport(
  passport,
  async email => await User.findOne({ email }),
  async id => await User.findOne({ id })
)

app.use(express.urlencoded({ extended: false }))
app.use(express.json())
app.use(flash())
app.use(passport.initialize())

// Endpoint para validar o token JWT 
app.post('/validate-token', async (req, res) => {

  const { token } = req.body;

  if (!token) return res.status(400).json({ error: 'Token is required.' });

  try {

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Retorna o usuário decodificado como payload
    res.status(200).json({ user: decoded });

  } catch (err) {

    console.error('Error validating token:', err.message);
    return res.status(401).json({ error: 'Invalid or expired token.' });

  }

});

// Login local
app.post('/login', (req, res, next) => {
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
app.post('/register', async (req, res) => {
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

  const existingUser = await User.findOne({ email: email })
  if (existingUser) {
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

    try {
      await axios.post(`${EVENT_BUS_URL}/events`, {
        type: 'UserRegistered',
        payload: {
          id: user.id,
          name: user.name,
          email: user.email
        }
      });
      console.log('Evento UserRegistered emitido para o Event Bus');
    } catch (eventBusErr) {
      console.error('Falha ao emitir evento UserRegistered para o Event Bus:', eventBusErr.message);
    }

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
app.delete('/logout', (req, res) => {
  res.status(200).json({ message: 'Logout simbólico com JWT. Basta remover o token no frontend.' })
})


app.post('/events', async (req, res) => {

  const event = req.body;
  console.log('Evento recebido:', event.type);
  res.status(200).send('Evento processado ou reconhecido');

})


mongoose.connect(mongoURI)
  .then(() => {

    console.log('✅ MongoDB: [OK]');

    app.listen(APP_PORT, async () => {
      console.log(`🟢 MSS-AUTENTICACAO (${APP_PORT}): [OK]`);

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

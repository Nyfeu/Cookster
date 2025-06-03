if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

const axios = require('axios');
const express = require('express');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken'); 
const cors = require('cors');
const Profile = require('./models/Profile'); 

const app = express();

const dbUser = process.env.DB_USER;
const dbPass = process.env.DB_PASS;
const jwtSecret = process.env.JWT_SECRET; 
const servicePort = 5000; 
const eventBusPort = 4000;


app.use(cors({
  origin: 'http://localhost:5173', 
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));


app.use(express.json());

function checkAuthenticated(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token não fornecido' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, jwtSecret);
    req.user = decoded; 
    next();
  } catch (err) {
    return res.status(403).json({ error: 'Token inválido ou expirado' });
  }
}


app.get('/profile/:userId', async (req, res) => {
    try {
        const { userId } = req.params;


        const profile = await Profile.findOne({ userId: userId }, 'bio profissao fotoPerfil');

        if (!profile) {
            return res.status(404).json({ message: `Perfil não encontrado para o usuário com ID: ${userId}` });
        }

        res.status(200).json({
            message: 'Perfil encontrado com sucesso!',
            data: profile
        });

    } catch (err) {
        console.error(`Erro ao buscar perfil para o usuário ${req.params.userId}:`, err.message);
        res.status(500).json({ message: 'Erro interno do servidor ao buscar perfil.' });
    }
});


app.post('/profile', async (req, res) => {
    try {
        const { userId, bio, profissao, fotoPerfil } = req.body;

        if (!userId) {
            return res.status(400).json({ message: 'O ID do usuário (userId) é obrigatório.' });
        }


        const existingProfile = await Profile.findOne({ userId: userId });
        if (existingProfile) {
            return res.status(409).json({ message: `Um perfil já existe para o usuário com ID: ${userId}` });
        }

   
        const defaultImageUrl = `default-profile.png`;


        const newProfile = new Profile({
            userId,
            bio: bio || '',
            profissao: profissao || '',
            fotoPerfil: fotoPerfil || defaultImageUrl 
        });

        await newProfile.save();

        res.status(201).json({
            message: 'Perfil criado com sucesso!',
            data: newProfile
        });

    } catch (err) {
        console.error('Erro ao criar perfil:', err.message);
        if (err.name === 'ValidationError') {
            return res.status(400).json({ message: err.message });
        }
        res.status(500).json({ message: 'Erro interno do servidor ao criar perfil.' });
    }
});


mongoose.connect(`mongodb+srv://${dbUser}:${dbPass}@cluster0.fbrwz1j.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0`)
  .then(() => {
    console.log('Conectado ao MongoDB');

    app.listen(servicePort, async () => {
      console.log(`mss-profile-service (localhost:${servicePort}): [OK]`);


      try {
        await axios.post(`http://localhost:${eventBusPort}/register`, { url: `http://localhost:${servicePort}` });
        console.log(`Event Bus Registration (http://localhost:${servicePort}): [OK]`);
      } catch (error) {
        console.error(`Event Bus Registration (http://localhost:${servicePort}): [FAILED]`, error.message);
      }
    });
  })
  .catch(err => {
    console.error('Erro ao conectar ao MongoDB:', err);
    process.exit(1); 
  });
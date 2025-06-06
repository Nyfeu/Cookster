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

const APP_PORT = 5000;
const SERVICE_ID = 'mss-profile-service';
const EVENT_BUS_URL = 'http://localhost:4000';
const defaultImageUrl = 'default-profile.jpeg';
const dbUser = process.env.DB_USER;
const dbPassword = process.env.DB_PASS;
const mongoURI = `mongodb+srv://${dbUser}:${dbPassword}@cluster0.fbrwz1j.mongodb.net/mss-profile-service?retryWrites=true&w=majority&appName=Cluster0`;

app.use(cors({
    origin: 'http://localhost:5173',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));


app.use(express.json());

const eventHandlers = { // Renomeei para 'eventHandlers' para clareza
  // Função que será chamada quando um evento 'UserCreated' for recebido
  UserRegistered: async (userData) => { // Adaptei o nome da função para 'UserCreated'
    try {
      console.log(`[x] Evento 'UserCreated' recebido para:`, userData);

      const { id: userId, name, email } = userData; // Renomeia 'id' do payload para 'userId'

      // Validação básica do userId recebido
      if (!userId) {
        console.warn(`[!] Evento 'UserCreated' recebido sem userId. Ignorando.`);
        return;
      }

      // 1. Verificar se o perfil já existe (para garantir idempotência)
      const existingProfile = await Profile.findOne({ userId: userId });

      if (existingProfile) {
        console.log(`[x] Perfil para o usuário ${userId} já existe. Ignorando criação duplicada.`);
        return;
      }

      // 3. Criar uma nova instância de perfil com informações preenchidas automaticamente
      const newProfile = new Profile({
        userId: userId,
        bio: `Olá! Sou ${name || 'um novo usuário'}. Bem-vindo(a)!`,
        profissao: 'Não informada',
        fotoPerfil: defaultImageUrl,
        email: email,
        name: name,
        descricao: 'Fale mais sobre você!'
      });

      await newProfile.save();
      console.log(`[+] Perfil criado automaticamente para o usuário: ${userId} (Nome: ${name || 'N/A'})`);

    } catch (error) {
      console.error('Erro ao processar evento UserCreated ou criar perfil:', error);
    }
  }
  // Se você tiver outros tipos de eventos no futuro, adicione-os aqui:
  // AnotherEventType: async (data) => { /* ... lógica ... */ }
};



app.get('/profile/:userId', async (req, res) => {
    try {
        const { userId } = req.params;


        const profile = await Profile.findOne({ userId: userId });

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

// Para Teste
app.post('/profile', async (req, res) => {
    try {
        const { id: userId, bio, profissao, fotoPerfil,email, nome, descricao } = req.body;

        if (!userId) {
            return res.status(400).json({ message: 'O ID do usuário (userId) é obrigatório.' });
        }


        const existingProfile = await Profile.findOne({ userId: userId });
        if (existingProfile) {
            return res.status(409).json({ message: `Um perfil já existe para o usuário com ID: ${userId}` });
        }


        const newProfile = new Profile({
            userId,
            bio: bio || '',
            profissao: profissao || '',
            fotoPerfil: fotoPerfil || defaultImageUrl,
            email: email || '',
            nome: nome || '',
            descricao: descricao || ''

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

app.post(`/events`, async (req, res) => {
   try {
    const evento = req.body; 
    console.log(`[Event Bus] Evento Recebido: Tipo=${evento.type}, Dados=`, evento.payload);

    if (eventHandlers[evento.type]) {
      await eventHandlers[evento.type](evento.payload);
    } else {
      console.warn(`[!] Tipo de evento desconhecido: ${evento.type}. Nenhuma função de tratamento encontrada.`);
    }
  } catch (e) {
    console.error('Erro ao processar evento do Event Bus:', e);
  } finally {
    res.end(); 
  }
});


mongoose.connect(mongoURI)
    .then(() => {

        console.log('✅ MongoDB: [OK]');

        app.listen(APP_PORT, async () => {
            console.log(`🟢 MSS-PROFILE-SERVICE (${APP_PORT}): [OK]`);

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
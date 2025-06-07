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

// Configurações do servidor
const APP_PORT = process.env.SERVICE_PORT || 5000;
const SERVICE_ID = 'mss-profile-service';
const EVENT_BUS_URL = process.env.EVENT_BUS_URL || 'http://localhost:4000';
const SERVICE_URL = process.env.SERVICE_URL || 'http://localhost';
const SERVICE_FULL_URL = SERVICE_URL + ':' + APP_PORT;
const defaultImageUrl = 'default-profile.jpeg';

// Configuração do MongoDB
const dbUser = process.env.DB_USER;
const dbPassword = process.env.DB_PASS;
const mongoURI = `mongodb+srv://${dbUser}:${dbPassword}@cluster0.fbrwz1j.mongodb.net/mss-profile-service?retryWrites=true&w=majority&appName=Cluster0`;

app.use(cors({
    origin: 'http://localhost:5173',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));


app.use(express.json());

const validateProfileUpdate = (req, res, next) => {
    const { fotoPerfil, bio, descricao, email, username: name } = req.body;

    if (!name || !email) {
        return res.status(400).json({ message: 'Nome e Email são campos obrigatórios.' });
    }

    if (email && !/.+@.+\..+/.test(email)) {
        return res.status(400).json({ message: 'Por favor, insira um endereço de email válido.' });
    }

    next();
};


const eventHandlers = {
    UserRegistered: async (userData) => {
        try {

            const { id: userId, name, email } = userData;

            if (!userId) {
                console.warn(`[!] Evento 'UserCreated' recebido sem userId. Ignorando.`);
                return;
            }

            const existingProfile = await Profile.findOne({ userId: userId });

            if (existingProfile) {
                console.log(`[x] Perfil para o usuário ${userId} já existe. Ignorando criação duplicada.`);
                return;
            }

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

app.post('/profile', async (req, res) => {
    try {
        console.log(req.body)
        const { id: userId, bio, profissao, fotoPerfil, email, nome, descricao } = req.body;

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

app.put('/profile/:userId', validateProfileUpdate, async (req, res) => {
    const { userId: paramUserId } = req.params;
    const { fotoPerfil, name, email, bio, descricao } = req.body;

    const updateFields = {};
    if (fotoPerfil !== undefined) updateFields.fotoPerfil = fotoPerfil;
    if (name !== undefined) updateFields.name = name;
    if (email !== undefined) updateFields.email = email;
    if (bio !== undefined) updateFields.bio = bio;
    if (descricao !== undefined) updateFields.descricao = descricao;

    try {
        const updatedProfile = await Profile.findOneAndUpdate(
            { userId: paramUserId },
            { $set: updateFields },
            { new: true, runValidators: true }
        ).select();

        if (!updatedProfile) {
            return res.status(404).json({ message: 'Perfil não encontrado.' });
        }

        res.status(200).json({
            message: 'Perfil atualizado com sucesso!',
            user: updatedProfile
        });

    } catch (err) {
        console.error('Erro ao atualizar perfil no MongoDB:', err.message);

        if (err.kind === 'ObjectId') {
            return res.status(400).json({ message: 'ID de usuário fornecido é inválido.' });
        }


        res.status(500).json({ message: 'Erro interno do servidor ao atualizar o perfil.' });
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
                    url: `${SERVICE_FULL_URL}/events`
                });

                console.log('📡 EVENT-BUS: [REGISTERED]');

            } catch (error) {

                console.error('❌ EVENT-BUS: [FAILED]');

            }

        });

    }).catch(_ => console.error('❌ MongoDB: [FAILED]'));
if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config();
}

const axios = require('axios');
const express = require('express');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const Profile = require('./models/Profile');
const User = require('./models/User');

const app = express();

const APP_PORT = 5000;
const SERVICE_ID = 'mss-profile-service';
const EVENT_BUS_URL = 'http://localhost:4000';

const dbUser = process.env.DB_USER;
const dbPassword = process.env.DB_PASS;
const mongoURI = `mongodb+srv://${dbUser}:${dbPassword}@cluster0.fbrwz1j.mongodb.net/mss-profile-service?retryWrites=true&w=majority&appName=Cluster0`;

app.use(cors({
    origin: 'http://localhost:5173',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));


app.use(express.json());


app.get('/profile/:userId', async (req, res) => {
    try {
        const { userId } = req.params;


        const profile = await Profile.findOne({ userId: userId })
            .populate({
                path: 'userId',
                model: 'User',
                localField: 'userId',
                foreignField: 'id',
                select: 'name email'
            })
            .exec();

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
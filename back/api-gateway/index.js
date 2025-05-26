if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config()
}

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const jwt = require('jsonwebtoken');
const morgan = require('morgan');
const cors = require('cors');

const app = express();
app.use(morgan('combined')); // Logging de requisições

app.use(cors({
    origin: 'http://localhost:5173',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// 1. Middleware de Autenticação Global
app.use(async (req, res, next) => {

    // Passo 1: Pegar o cabeçalho de autenticação
    const authHeader = req.headers.authorization;

    // Rotas públicas (ex: login, registro etc.)
    const publicRoutes = [
        '/auth/login',
        '/auth/register',
        '/ingredient/health'
    ];

    // Passo 2: Verificar se o cabeçalho está presente e é válido
    if (publicRoutes.includes(req.path)) return next();

    try {

        // Passo 3: Extrair o token do cabeçalho
        const token = authHeader.split(' ')[1];

        // Passo 4: Validar o token (comunicação com Auth Service)
        const decoded = await verifyToken(token);

        // Passo 5: Adicionar dados do usuário à requisição
        req.user = decoded;

        // Passo 6: Liberar acesso ao microserviço
        next();

    } catch (error) {

        // Passo 7: Bloquear se houver qualquer erro
        res.status(401).json({ error: 'Unauthorized' });

    }

});

// 2. Configuração de Proxies para Microserviços
const services = {
    auth: {
        target: 'http://localhost:3000',
        publicRoutes: ['/register', '/login']
    },
    ingredient: {
        target: 'http://localhost:8000',
        publicRoutes: ['/health']
    }
};

// 3. Rotas e Balanceamento Básico
Object.entries(services).forEach(([route, config]) => {
    app.use(`/${route}`, createProxyMiddleware({
        target: config.target,
        changeOrigin: true,
        pathRewrite: { [`^/${route}`]: '' },
        onError: (err, req, res) => {
            console.error(`Service ${route} error:`, err);
            res.status(503).json({ error: 'Service unavailable' });
        }
    }));
});

// 4. Função de Verificação de Token (Comunicação com Auth Service)
async function verifyToken(token) {
    return jwt.verify(token, process.env.JWT_SECRET);
}

app.listen(2000, () => console.log('Gateway running on port 2000'));
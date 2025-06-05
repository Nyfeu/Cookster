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

// 1. Configuração de CORS para permitir requisições do frontend
app.use(cors({
    origin: 'http://localhost:5173',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// 2. Configuração de Proxies para Microserviços
const services = {
    auth: {
        target: 'http://localhost:3000',
        publicRoutes: ['/register', '/login'],
        requiresUserId: false
    },
    debug: {
        target: 'http://localhost:7000',
        requiresUserId: true
    },
    ingredient: {
        target: 'http://localhost:8000',
        publicRoutes: ['/health'],
        requiresUserId: false
    },
    profile: {
        target: 'http://localhost:5000',
        requiresUserId: true
    },
    pantry:{
        target: 'http://localhost:3001',
        requiresUserId: true
    }
};

// 3. Gerar lista de rotas públicas a partir de services
const publicRoutes = [];

Object.entries(services).forEach(([route, config]) => {
    if (config.publicRoutes) {
        config.publicRoutes.forEach(subRoute => {
            publicRoutes.push(`/${route}${subRoute}`);
        });
    }
});

// 4. Middleware de Autenticação Global
app.use(async (req, res, next) => {

    // Passo 1: Identificar o serviço a partir do caminho
    const serviceName = req.path.split('/')[1];
    const serviceConfig = services[serviceName];

    // Passo 2: Pegar o cabeçalho de autenticação
    const authHeader = req.headers.authorization;

    // Passo 3: Verificar se a rota atual é pública
    if (publicRoutes.includes(req.path)) return next();

    try {

        // Passo 4: Extrair o token do cabeçalho
        const token = authHeader.split(' ')[1];

        // Passo 5: Validar o token (comunicação com Auth Service)
        const decoded = await verifyToken(token);

        // Passo 6: Adicionar dados do usuário à requisição
        req.user = decoded;

        // Passo 7: Adiciona o user id aos headers
        if (serviceConfig.requiresUserId)
            req.headers['user-id'] = decoded.id; 

        // Passo 8: Liberar acesso ao microserviço
        next();

    } catch (error) {

        // Passo 7: Bloquear se houver qualquer erro
        res.status(401).json({ error: 'Unauthorized' });

    }

});

// 5. Rotas e Balanceamento Básico
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

// 6. Função de Verificação de Token (Comunicação com Auth Service)
async function verifyToken(token) {
    return jwt.verify(token, process.env.JWT_SECRET);
}

// 7. Configura o gateway para escutar na porta 2000
app.listen(2000, () => console.log(`🟢 API-GATEWAY (2000): [OK]`));
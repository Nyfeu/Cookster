if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config()
}

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const jwt = require('jsonwebtoken');
const morgan = require('morgan');
const cors = require('cors');
const axios = require('axios');

const app = express();
app.use(morgan('combined')); // Logging de requisições

app.use((req, res, next) => {
    console.log(`[API_GATEWAY_DEBUG] Original URL: ${req.originalUrl}, Path: ${req.path}`);
    next();
});

// 1. Configuração de CORS para permitir requisições do frontend
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// 2. Configuração de Proxies para Microserviços
const services = {

    auth: {
        target: process.env.AUTH_SERVICE_URL || 'http://localhost:3000',
        publicRoutes: ['/register', '/login'],
        requiresUserId: false
    },

    ingredient: {
        target: process.env.INGREDIENT_SERVICE_URL || 'http://localhost:8000',
        publicRoutes: ['/health'],
        requiresUserId: false
    },

    profile: {
        target: process.env.PROFILE_SERVICE_URL || 'http://localhost:5000',
        requiresUserId: true
    },

    pantry:{
        target: process.env.PANTRY_SERVICE_URL || 'http://localhost:3001',
        requiresUserId: true
    },
    
    recipe: {
        target: process.env.RECIPE_SERVICE_URL || 'http://localhost:9000',
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

    // Se a rota não é pública e não há token, retorna 401
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized: Token not provided or invalid format.' });
    }

    try {

        // Passo 4: Extrair o token do cabeçalho
        const token = authHeader.split(' ')[1];

        // Passo 5: Delegar a validação do token ao Auth Service
        const authServiceResponse = await axios.post(`${services.auth.target}/validate-token`, { token });
        const decoded = authServiceResponse.data.user;

        // Passo 6: Adicionar dados do usuário à requisição
        req.user = decoded;

        // Passo 7: Adiciona o user id aos headers
        if (serviceConfig.requiresUserId)
            req.headers['user-id'] = decoded.id; 

        // Passo 8: Liberar acesso ao microserviço
        next();

    } catch (error) {

        // Passo 9: Bloquear se houver qualquer erro na validação do token
        console.error('Token validation error:', error.response ? error.response.data : error.message);
        res.status(401).json({ error: 'Unauthorized: Invalid or expired token.' });

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

// 6. Configura o gateway para escutar na porta 2000
app.listen(2000, () => console.log(`🟢 API-GATEWAY (2000): [OK]`));
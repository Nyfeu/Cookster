# API Gateway - Microservices Architecture

Este é um **API Gateway** desenvolvido com **Node.js** e **Express**, responsável por rotear requisições entre diferentes microserviços, centralizar autenticação via JWT e gerenciar CORS e logging.

## 🚀 Funcionalidades

- Proxy reverso para microserviços 
    - Esconde os servidores internos do cliente
    - Cliente → Proxy → Servidores internos
- Middleware global de autenticação com JWT
- Rotas públicas configuráveis
- Gerenciamento de CORS
- Logging de requisições via `morgan`
- Tratamento de erros quando os serviços estão indisponíveis

---

## 📦 Instalação

1. **Clone o repositório:**

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
```

2. **Instale as dependências:**
```bash
npm install
```

3. **Crie um arquivo `.env` na raiz do projeto com o seguinte conteúdo:

```plain-text
JWT_SECRET=sua_chave_secreta
```

## 🔧 Estrutura dos Microserviços

> Ainda será atualizada para cobrir todos os microserviços do sistema

| Serviço    | Porta | Descrição                             |
| ---------- | ----- | ------------------------------------- |
| Auth       | 3000  | Serviço de autenticação               |
| Ingredient | 8000  | Serviço de autocomple de ingredientes |

## 🌐 Rotas

### 🔑 Rotas Públicas

```mermaid
sequenceDiagram
    participant Frontend
    participant API Gateway
    participant Auth Service
    participant Microsserviço

    Frontend->>API Gateway: Requisição com token
    alt Rota pública
        API Gateway->>Microsserviço: Encaminha direto
    else Rota protegida
        API Gateway->>API Gateway: Valida token
        API Gateway->>Microsserviço: Encaminha com contexto do usuário
    end
    Microsserviço->>API Gateway: Resposta
    API Gateway->>Frontend: Resposta
```

Definidas diretamente na lista services:
```javascript
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
```

Exemplos de rotas públicas:
- POST `/auth/login`
- POST `/auth/register`
- GET `/ingredient/health`

### 🔒 Rotas Protegidas

Todas as demais rotas exigem um token JWT no header:
```http
Authorization: Bearer <seu_token>
```

> A proteção de rotas é essencial não apenas para garantir segurança, mas também para mitigar sobrecarga em serviços sensíveis e computacionalmente dispendiosos, como mecanismos de busca ou autocomplete de ingredientes, que são altamente suscetíveis a picos de acesso.

```mermaid
sequenceDiagram
    participant Frontend
    participant API Gateway
    participant Auth Service
    participant Microserviço

    Frontend->>API Gateway: POST /auth/login (credenciais)
    API Gateway->>Auth Service: Proxy para /login
    Auth Service->>API Gateway: Token JWT
    API Gateway->>Frontend: Retorna token

    Frontend->>API Gateway: Requisição protegida (com token)
    API Gateway->>API Gateway: Valida token
    API Gateway->>Microserviço: Proxy com user context
    Microserviço->>API Gateway: Resposta
    API Gateway->>Frontend: Dados solicitados
```

Exemplo:
- GET `/ingredient/suggestion...`

## ▶️ Executando o Gateway

```bash
npm run devStart
```

O gateway estará disponível em:
```plain-text
http://localhost:2000
```

## 🗺️ Exemplo de Requisição com Token

```plain-text
GET /ingredient/sugestoes?termo=ban HTTP/1.1
Host: localhost:2000
Authorization: Bearer <seu_token_aqui>
```
> Sem as angle brackets (<>) e sem aspas (")

## 🧠 Observações

- As rotas são automaticamente roteadas para os microserviços correspondentes. Por exemplo:
    - `/auth/login` → `http://localhost:3000/login`
    - `/ingredient/health` → `http://localhost:8000/health`
- O middleware de autenticação protege todas as rotas, exceto aquelas declaradas como públicas.

## 🛠️ Tecnologias Utilizadas

- Node.js
- Express.js
- http-proxy-middleware
- jsonwebtoken
- dotenv
- cors
- morgan

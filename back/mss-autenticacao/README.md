# Cookster Auth Service 🍽️

Este projeto é um microsserviço de autenticação para a aplicação **Cookster**, desenvolvido com Node.js, Express e Passport.js. Ele implementa autenticação local com JWT e suporte futuro a OAuth (Google e Facebook).

## 📦 Tecnologias Utilizadas

- Node.js
- Express.js
- Passport.js (Local, Google, Facebook)
- JWT (JSON Web Token)
- bcrypt
- dotenv

---

## ⚙️ Instalação e Execução

```bash
git clone https://github.com/seuusuario/cookster-auth.git
cd cookster/back/mss-autenticacao
npm install
npm run dev
```

Crie um arquivo `.env` com as seguintes variáveis:

```env
JWT_SECRET=sua_chave_secreta
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
FACEBOOK_CLIENT_ID=...
FACEBOOK_CLIENT_SECRET=...
```

---

## 🔐 Autenticação

O sistema usa JWT para proteger rotas privadas. O token é gerado após login e deve ser incluído no header de requisições subsequentes como:

```
Authorization: Bearer <token>
```

---

## 📌 Rotas da API

### 1. `POST /register`

**Descrição:** Registra um novo usuário.

**Body esperado:**

```json
{
  "name": "João",
  "email": "joao@example.com",
  "password": "senhaSegura123"
}
```

**Respostas:**

| Código | Descrição                          |
|--------|------------------------------------|
| 201    | Usuário registrado com sucesso     |
| 400    | Campos ausentes                    |
| 409    | Usuário já existe                  |

---

### 2. `POST /login`

**Descrição:** Autentica um usuário e retorna um token JWT.

**Body esperado:**

```json
{
  "email": "joao@example.com",
  "password": "senhaSegura123"
}
```

**Respostas:**

| Código | Descrição                          |
|--------|------------------------------------|
| 200    | Login bem-sucedido + token         |
| 400    | Campos ausentes                    |
| 401    | Credenciais inválidas              |

---

### 3. `GET /dashboard` (rota protegida)

**Descrição:** Acesso apenas com JWT. Simula a página privada do usuário após login.

**Headers:**

```
Authorization: Bearer <token>
```

**Respostas:**

| Código | Descrição                          |
|--------|------------------------------------|
| 200    | Acesso permitido + dados do usuário|
| 401    | Token ausente ou inválido          |

---

### 4. `GET /`

**Descrição:** Página inicial pública, com saudação.

**Respostas:**

| Código | Descrição                          |
|--------|------------------------------------|
| 200    | Mensagem pública + dados do usuário (se autenticado via session) |

> Obs: se você só estiver usando JWT, esta rota deve ser pública ou ajustada para também usar o `checkToken`.

---

## 🧪 Testando com Postman

### ✅ Registro

- **URL:** `POST http://localhost:3000/register`
- **Body (JSON):**
```json
{
  "name": "Maria",
  "email": "maria@example.com",
  "password": "senhaSegura"
}
```

- **Possíveis respostas:**
  - 201 → Registro OK
  - 409 → Usuário já existe

---

### 🔐 Login

- **URL:** `POST http://localhost:3000/login`
- **Body (JSON):**
```json
{
  "email": "maria@example.com",
  "password": "senhaSegura"
}
```

- **Resposta esperada:**
```json
{
  "message": "Login bem-sucedido",
  "token": "<token JWT>",
  "user": {
    "id": "...",
    "name": "Maria",
    "email": "maria@example.com"
  }
}
```

- **Erros comuns:**
  - 401 → Senha ou email incorretos
  - 400 → Campos vazios

---

### 🔒 Dashboard (Rota protegida)

- **URL:** `GET http://localhost:3000/dashboard`
- **Headers:**
```
Authorization: Bearer <token>
```

- **Resposta esperada:**
```json
{
  "message": "Bem-vindo ao painel!",
  "user": {
    "id": "...",
    "name": "Maria",
    "email": "maria@example.com"
  }
}
```

- **Erros comuns:**
  - 401 → Token ausente ou inválido

---

## 🚧 Melhorias Futuras

- Conexão com banco de dados real (MongoDB, PostgreSQL)
- Sistema de refresh token
- Logout via blacklist de tokens
- Email de confirmação de cadastro

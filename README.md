# Cookster 👨🏻‍🍳

**Cookster** é um aplicativo web que ajuda os usuários a gerenciarem suas despensas de ingredientes e compartilharem receitas, tudo isso promovendo o consumo consciente e o combate ao desperdício de alimentos.

## 👨🏻‍👩🏻‍👦🏻‍👦🏻 Integrantes do Grupo

| Nome | R.A. |
|:---|:--:|
| André Solano Ferreira Rodrigues Maiolini | 19.02012-0 |
| Durval Consorti Soranz de Barros Santos  | 22.01097-0 |
| Leonardo Roberto Amadio | 22.01300-8 | 
| Lucas Castanho Paganotto Carvalho | 22.00921-3 | 

## 🌟 Por que escolher o Cookster?

Você já abriu a geladeira e viu ingredientes esquecidos prestes a vencer? Ou ficou sem ideias para transformar o que tem em casa em uma refeição incrível? O Cookster resolve isso!

Somos mais que um app de receitas: somos uma comunidade que combate o desperdício alimentar, conectando sua criatividade na cozinha ao consumo consciente. Com inteligência e colaboração, ajudamos você a:

- Economizar tempo e dinheiro: receitas inteligentes baseadas no que você já tem.
- Reduzir o desperdício: alertas de validade e priorização de ingredientes próximos do vencimento.
- Inspirar e ser inspirado: compartilhe suas criações e descubra pratos inovadores de outros usuários.
- Cozinhar com propósito: cada receita preparada contribui para um mundo mais sustentável.

## 🌍 Visão Geral

Combinando uma abordagem prática com funcionalidades sociais, o Cookster permite:

- Monitorar ingredientes (quantidade, validade, categoria).
- Receber sugestões de receitas baseadas nos ingredientes disponíveis.
- Priorizar receitas com base em ingredientes próximos da validade.
- Compartilhar receitas com outros usuários e navegar por receitas de outros.
- Buscar receitas por autor, nome, ingredientes ou tags.
- Reduzir o desperdício de alimentos, alinhando-se com os Objetivos de Desenvolvimento Sustentável (ODS).

## 🌱 Alinhado com os ODS da ONU

O Cookster contribui diretamente com o ODS 12 (Consumo e Produção Responsáveis) ao:
- Reduzir o desperdício de alimentos nas casas dos usuários.
- Promover educação sobre planejamento de compras e aproveitamento integral.
- Criar uma rede de usuários conscientes.

> Cookster: Porque cada ingrediente merece virar história, não lixo. ♻️🍴

## 🚀 Funcionalidades Principais

- 📦 **Gestão de Despensa**: adição, edição e exclusão de ingredientes.
- 🔪 **Receitas Inteligentes**: sugestões baseadas no que você já tem.
- ⏰ **Validade e Prioridade**: sugestões com base na urgência de uso dos ingredientes.
- 📲 **Rede Social de Receitas**: explore, publique, curta e comente receitas.
- 🔍 **Filtros Poderosos**: por nome, autor, ingredientes disponíveis, tags e mais.
- ✅ **Sustentabilidade**: foco em consumo consciente e combate ao desperdício.

## ⚙️ Tecnologias

🖥️ **Frontend:**
- React.js
- Axios

🌐 **Backend (Arquitetura de Microsserviços):**
- Node.js
- FastAPI
- Python
- Express.js

## ▶️ Como Executar o Projeto

Para colocar o Cookster em funcionamento, você precisará iniciar todos os microsserviços do back-end e rodar o frontend.

### 1. Clonar o Repositório

Primeiro, clone o repositório do Cookster para sua máquina local:

```bash
git clone https://github.com/Nyfeu/Cookster.git
cd Cookster
```

### 2. Inicializar Serviços do Back-end

Para cada serviço, deve-se instalar as depedências usando npm e colocá-lo em execução:
- api-gateway
- event-bus
- mss-autenticacao
- mss-ingredient-classifier (Python)
- mss-pantry
- mss-profile-service
- mss-recipe

Deve-se executar os seguintes comandos:

```bash
cd back/mss-a-ser-inicializado
npm install
npm run devStart
```

> ⚠️ Deve-se inicializar `event-bus` antes dos demais serviços. Para que eles possam se registrar para receber eventos do barramento.

Com exceção de mss-ingredient-classifier que foi desenvolvido em Python. A metodologia para execução dele é descrita no README.md em [mss-ingredientes-classifier](https://github.com/Nyfeu/Cookster/back/mss-ingredient-classifier).

Precisa-se também, colocar um arquivo `.env` para cada serviço, como o seguinte:
```
JWT_SECRET=sua_chave_secreta_jwt
GOOGLE_CLIENT_ID=seu_client_id_google
GOOGLE_CLIENT_SECRET=seu_client_secret_google
FACEBOOK_CLIENT_ID=seu_client_id_facebook
FACEBOOK_CLIENT_SECRET=seu_client_secret_facebook
DB_USER=seu_db_user
DB_PASS=seu_db_password
```

Caso se opte por utilizar containers Docker, um único arquivo `.env` é necessário na raíz.

### 3. Inicializar Servidor Front-end

```bash 
cd front
npm install
npm run dev
```

### 4. Docker-Compose (Alternativamente)

Para evitar ter que inicializar cada serviço individualmente, criou-se um arquivo `docker-compose.yml` na raiz do projeto, que realiza o deploy de todos os serviços - exceto o front-end. 

Para isso, é necessário criar (build) as imagens e inicializar os containers. Pode-se realizar isso da seguinte forma:

```bash
docker-compose up --build
```

ou

```bash
docker-compose build
docker-compose up
```

Deve-se adicionar à raíz do projeto o arquivo `.env`:
```
JWT_SECRET=sua_chave_secreta_jwt
GOOGLE_CLIENT_ID=seu_client_id_google
GOOGLE_CLIENT_SECRET=seu_client_secret_google
FACEBOOK_CLIENT_ID=seu_client_id_facebook
FACEBOOK_CLIENT_SECRET=seu_client_secret_facebook
DB_USER=seu_db_user
DB_PASS=seu_db_password
```

---

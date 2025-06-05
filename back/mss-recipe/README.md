# MSS-RECIPE: Microsserviço de Receitas e Despensa

Este microsserviço, denominado **mss-recipe**, é responsável por gerenciar receitas e uma cópia da despensa de ingredientes dos usuários. Ele permite buscar receitas por diversos critérios, sugerir receitas com base nos ingredientes disponíveis na despensa do usuário e interage com um Event Bus para manter a consistência da despensa dos usuários.

## Propósito

O principal propósito do MSS-RECIPE é:

* **Gerenciar Receitas**: Armazenar e permitir a consulta de receitas com detalhes como nome, ingredientes e instruções.
* **Sugestão de Receitas**: Oferecer mecanismo para sugerir receitas aos usuários com base nos ingredientes que eles possuem em sua despensa.
* **Integração com Event Bus**: Consumir eventos relacionados a adições e remoções de ingredientes na despensa do usuário, garantindo que o estado da despensa no microsserviço seja sempre consistente.
* **Flexibilidade de Busca**: Permitir a busca de receitas por ID do usuário, nome da receita e ingredientes específicos.

## Como Funciona

O MSS-RECIPE é construído utilizando Node.js e Express, com persistência de dados no MongoDB. Ele se integra a um Event Bus para comunicação assíncrona com outros microsserviços.

1.  **Conexão com MongoDB**: Ao iniciar, o microsserviço se conecta a um banco de dados MongoDB Atlas, utilizando credenciais fornecidas através de variáveis de ambiente.
2.  **Registro no Event Bus**: Após a conexão bem-sucedida com o MongoDB, o microsserviço se registra automaticamente no Event Bus, informando seu endereço para que possa receber eventos.
3.  **Endpoints RESTful**: Expõe uma série de endpoints HTTP para operações de consulta de receitas e sugestão de receitas.
4.  **Consumo de Eventos**: Possui um endpoint `/events` que recebe eventos do Event Bus. Atualmente, ele processa eventos de `IngredientAdded` e `IngredientRemoved`, atualizando a despensa do usuário no MongoDB.
5.  **Paginação**: As consultas de receitas e sugestões de receitas implementam paginação para lidar com grandes volumes de dados de forma eficiente.

## Pré-requisitos

Antes de rodar o microsserviço, certifique-se de ter o seguinte instalado:

* **Node.js**
* **npm**: Gerenciador de pacotes Node.js.
* **MongoDB Atlas Cluster**: É necessário um cluster MongoDB Atlas configurado.
* **Event Bus**: O Event Bus (rodando em `http://localhost:4000`) deve estar em execução para que o microsserviço possa se registrar e receber eventos.

## Configuração de Ambiente

Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis de ambiente:

```
DB_USER=seu_usuario_mongodb
DB_PASS=sua_senha_mongodb
```

## Como Rodar

Siga os passos abaixo para rodar o microsserviço:

1.  **Clone o repositório** (se ainda não o fez):
    ```bash
    git clone https://github.com/Nyfeu/Cookster.git
    cd back\mss-recipe 
    ```
2.  **Instale as dependências**:
    ```bash
    npm install
    ```
3.  **Inicie o microsserviço**:
    ```bash
    npm run devStart
    ```

Após iniciar, você deverá ver as seguintes mensagens no console:

```
✅ Conectado ao MongoDB
🟢 MSS-RECIPE (http://localhost:5000): [OK]
📡 Registrado no Event Bus com sucesso
```

O microsserviço estará rodando na porta `5000` (ou na porta definida em `APP_PORT`).

## Endpoints

### 1. Consultar Receitas

* **URL**: `/recipes`
* **Método**: `GET`
* **Descrição**: Retorna uma lista de receitas, com opções de filtro e paginação.
* **Parâmetros de Query**:
    * `user_id` (opcional): Filtra receitas pelo ID do usuário que a criou.
    * `name` (opcional): Filtra receitas pelo nome (busca insensível a maiúsculas/minúsculas).
    * `ingredients` (opcional): Uma lista de ingredientes separados por vírgula. Retorna receitas que contenham *todos* os ingredientes especificados.
    * `page` (opcional): Número da página para paginação (padrão: `1`).
    * `limit` (opcional): Número de receitas por página (padrão: `10`).
* **Exemplos**:
    * `GET /recipes`
    * `GET /recipes?user_id=123`
    * `GET /recipes?name=bolo%20de%20chocolate`
    * `GET /recipes?ingredients=farinha,leite,ovos`
    * `GET /recipes?name=frango&page=2&limit=5`
* **Resposta (Sucesso - Status 200 OK)**: Um array de objetos de receita.
    ```json
    [
        {
            {
                "_id": "68418757ea0cf6733b142a67",
                "user_id": "68418757ea0cf6733b142a62",
                "name": "Bolo Simples de Chocolate",
                "description": "Receita básica de bolo de chocolate para iniciantes",
                "prep_time": 20,
                "cook_time": 40,
                "total_time": 0,
                "servings": 8,
                "tags": [
                "sobremesa",
                "fácil",
                "chocolate"
                ],
                "steps": [
                "Pré-aquecer forno a 180°C",
                "Misturar ingredientes secos em uma tigela",
                "Adicionar ingredientes líquidos e misturar até homogêneo",
                "Assar por 40 minutos e deixar esfriar"
                ],
                "ingredients": [
                {
                    "name": "farinha de trigo",
                    "quantity": 300,
                    "unit": "g",
                    "note": null
                },
                {
                    "name": "açúcar",
                    "quantity": 200,
                    "unit": "g",
                    "note": null
                },
                {
                    "name": "chocolate em pó",
                    "quantity": 80,
                    "unit": "g",
                    "note": "achocolatado"
                },
                {
                    "name": "ovos",
                    "quantity": 3,
                    "unit": "unidade",
                    "note": null
                },
                {
                    "name": "leite",
                    "quantity": 250,
                    "unit": "ml",
                    "note": null
                },
                {
                    "name": "óleo",
                    "quantity": 120,
                    "unit": "ml",
                    "note": "vegetal"
                },
                {
                    "name": "fermento",
                    "quantity": 1,
                    "unit": "colher",
                    "note": null
                }
                ],
                "utensils": [
                "forma",
                "batedeira",
                "tigelas"
                ],
                "image_url": "https://exemplo.com/bolo-chocolate.jpg",
                "created_at": "2025-06-05T12:02:31.259Z",
                "updated_at": "2025-06-05T12:02:31.259Z",
                "__v": 0
            }
        }
    ]
    ```
* **Resposta (Erro - Status 500 Internal Server Error)**:
    ```json
    {
        "error": "Erro ao buscar receitas."
    }
    ```

### 2. Consultar Receita por ID

* **URL**: `/recipes/:id`
* **Método**: `GET`
* **Descrição**: Retorna uma única receita pelo seu ID.
* **Parâmetros de Path**:
    * `id` (obrigatório): O ID único da receita.
* **Exemplo**:
    * `GET /recipes/60c72b2f9b1d8b001c8e4c1a`
* **Resposta (Sucesso - Status 200 OK)**: Um objeto de receita.
    
* **Resposta (Não Encontrado - Status 404 Not Found)**:
    ```json
    {
        "error": "Receita não encontrada."
    }
    ```
* **Resposta (Erro - Status 500 Internal Server Error)**:
    ```json
    {
        "error": "Erro ao buscar receita."
    }
    ```

### 3. Sugerir Receitas com Base na Despensa

* **URL**: `/suggest`
* **Método**: `GET`
* **Descrição**: Sugere receitas com base nos ingredientes que o usuário possui em sua despensa. As receitas sugeridas devem ter *todos* os ingredientes presentes na despensa do usuário.
* **Parâmetros de Query**:
    * `user_id` (obrigatório): O ID do usuário para o qual a sugestão será feita.
    * `name` (opcional): Filtra as sugestões pelo nome da receita (busca insensível a maiúsculas/minúsculas).
    * `page` (opcional): Número da página para paginação (padrão: `1`).
    * `limit` (opcional): Número de receitas por página (padrão: `10`).
* **Exemplos**:
    * `GET /suggest?user_id=user456`
    * `GET /suggest?user_id=user456&name=salada`
* **Resposta (Sucesso - Status 200 OK)**: Um array de objetos de receita.
* **Resposta (Requisição Inválida - Status 400 Bad Request)**:
    ```json
    {
        "error": "user_id é obrigatório."
    }
    ```
* **Resposta (Não Encontrado - Status 404 Not Found)**:
    ```json
    {
        "error": "Nenhum ingrediente encontrado na despensa do usuário."
    }
    ```
* **Resposta (Erro - Status 500 Internal Server Error)**:
    ```json
    {
        "error": "Erro ao buscar receitas."
    }
    ```

### 4. Receber Eventos do Event Bus

* **URL**: `/events`
* **Método**: `POST`
* **Descrição**: Este endpoint é usado exclusivamente pelo Event Bus para enviar eventos ao microsserviço. Ele não deve ser chamado diretamente por clientes externos.
* **Corpo da Requisição (JSON)**:
    ```json
    {
        "type": "TipoDoEvento",
        "payload": {
            // Dados específicos do evento
        }
    }
    ```
* **Tipos de Eventos Suportados**:
    * `IngredientAdded`:
        * **Payload**: `{ "userId": "string", "ingredient": { "nome": "string", "categoria": "string" } }`
        * **Ação**: Adiciona um ingrediente à despensa do usuário. Se a despensa não existir, uma nova é criada. Ignora a adição se o ingrediente (case-insensitive) já existir para o usuário.
    * `IngredientRemoved`:
        * **Payload**: `{ "userId": "string", "ingredient": { "nome": "string", "categoria": "string" } }`
        * **Ação**: Remove um ingrediente da despensa do usuário. A remoção é feita de forma case-insensitive.
* **Resposta (Sucesso - Status 200 OK)**:
    ```
    Evento processado com sucesso
    ```
* **Resposta (Erro - Status 500 Internal Server Error)**:
    ```
    Erro interno do servidor ao processar evento.
    ```

## Tecnologias Utilizadas
- Node.js
- Express.js
- Mongoose (ODM para MongoDB)
- MongoDB Atlas (Banco de dados)
- Axios (para requisições HTTP)
- CORS (Middleware para Cross-Origin Resource Sharing)
- Dotenv (para variáveis de ambiente)
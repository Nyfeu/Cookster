# Importa as bibliotecas necessárias =======================================

# FastAPI é um framework moderno e rápido para construir APIs com Python
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

# ChromaDB é um banco de dados vetorial para armazenar embeddings
import chromadb
from chromadb.config import Settings

# SentenceTransformer é usado para gerar embeddings de texto
from sentence_transformers import SentenceTransformer

# Carrega os dados de ingredientes de um arquivo JSON
from data.dados import carregar_ingredientes

# Logging é usado para registrar informações e erros
import logging

# Pydantic é usado para definir e validar dados
from pydantic import BaseModel

# Para manipulação de variáveis de ambiente
import os
from dotenv import load_dotenv

# Configuração básica de logging ===========================================

# -> Cria um sistema de registro de eventos para monitoramento
# -> Formato padrão: Data - Nome do Logger - Nível - Mensagem

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Modelo de resposta para validação ========================================

# -> Define o formato padrão das respostas da API

class SugestoesResponse(BaseModel):
    termo: str
    sugestoes: list[str]
    count: int

# Carrega variáveis do .env ================================================

# -> Carrega variáveis de ambiente do arquivo .env

load_dotenv() 

# -> Define variáveis de ambiente com valores padrão

EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "all-MiniLM-L6-v2")
CHROMA_DB_PATH = os.getenv("CHROMA_DB_PATH", "./chroma_data")
MIN_QUERY_LENGTH = 2
MAX_RESULTS = 5

# Inicializa o aplicativo FastAPI ==========================================

app = FastAPI(
    title="API de Autocomplete para Ingredientes",
    description="Microsserviço para sugestão de ingredientes culinários",
    version="1.0.0",
    docs_url="/docs",
    redoc_url=None
)

# Configuração de CORS =====================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "*").split(","),
    allow_methods=["GET"],
    allow_headers=["Content-Type"],
    max_age=3600
)

# Inicialização de componentes =============================================

@app.on_event("startup")
async def startup_db():

    # 1. Carrega modelo de embeddings
    # 2. Conecta ao ChromaDB
    # 3. Popula banco de dados, caso esteja vazio

    try:

        global model, collection
        
        # Carrega o modelo de embeddings
        model = SentenceTransformer(EMBEDDING_MODEL)
        logger.info(f"Modelo '{EMBEDDING_MODEL}' carregado com sucesso")
        
        # Configura ChromaDB com persistência
        client = chromadb.PersistentClient(
            path=CHROMA_DB_PATH,
            settings=Settings(allow_reset=True)
        )
        
        # Cria/recupera a collection
        collection = client.get_or_create_collection(
            name="ingredientes",
            metadata={"hnsw:space": "cosine"}
        )
        
        # Popula dados apenas se a collection estiver vazia
        if not collection.count():
            ingredientes = carregar_ingredientes()
            documentos = []
            metadados = []
            
            for idx, item in enumerate(ingredientes):
                doc = f"{item['nome']} | {' '.join(item['sinonimos'])}"
                documentos.append(doc)
                metadados.append({"nome": item["nome"]})
            
            embeddings = model.encode(documentos).tolist()
            collection.add(
                documents=documentos,
                embeddings=embeddings,
                metadatas=metadados,
                ids=[str(i) for i in range(len(documentos))]
            )
            logger.info(f"Banco de dados populado com {len(ingredientes)} ingredientes")
    except Exception as e:
        logger.error(f"Erro na inicialização: {str(e)}")
        raise

# Endpoint para sugestões de ingredientes ==================================

# -> Recebe um termo de pesquisa
# -> Retorna até 5 sugestões de ingredientes com base no termo

@app.get(
    "/sugestoes",
    response_model=SugestoesResponse,
    summary="Obter sugestões de ingredientes",
    description="Retorna até 5 sugestões de ingredientes com base no termo pesquisado",
    tags=["Autocomplete"]
)
async def obter_sugestoes(
    termo: str = Query(..., min_length=MIN_QUERY_LENGTH, example="leite")
):
    try:
        # Gera embedding
        embedding = model.encode([termo]).tolist()
        
        # Consulta o banco de dados
        result = collection.query(
            query_embeddings=embedding,
            n_results=MAX_RESULTS,
            include=["metadatas", "distances"]
        )
        
        sugestoes = [item["nome"] for item in result["metadatas"][0]]
        
        return {
            "termo": termo,
            "sugestoes": sugestoes,
            "count": len(sugestoes)
        }
        
    except Exception as e:
        logger.error(f"Erro na busca por '{termo}': {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Erro interno no processamento da solicitação"
        )

# Health Check =========================================================

# -> Endpoint para verificar o status do serviço
# -> Retorna informações sobre o modelo, status do banco de dados 
#    e total de ingredientes

@app.get("/health", include_in_schema=False)
async def health_check():
    return {
        "status": "online",
        "details": {
            "model": EMBEDDING_MODEL,
            "db_status": "ok" if collection.count() > 0 else "empty",
            "total_ingredientes": collection.count()
        }
    }

# ==========================================================================
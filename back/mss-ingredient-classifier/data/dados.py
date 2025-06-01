import json
from pathlib import Path

def carregar_ingredientes():
    caminho = Path(__file__).parent / "ingredientes.json"
    with open(caminho, "r", encoding="utf-8") as arquivo:
        return json.load(arquivo)
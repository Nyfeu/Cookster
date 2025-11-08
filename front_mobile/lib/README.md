# 🏗️ Arquitetura do Projeto Flutter

Este documento descreve a estrutura e as decisões arquiteturais do projeto, com base em princípios de **Clean Architecture** e **práticas do ecossistema Flutter**.  

## 📁 Estrutura de Pastas

```
lib/
│
├── core/ # Recursos globais e independentes de regra de negócio
│ ├── theme/ # Definições de tema, tipografia e paleta de cores
│ └── utils/ # Funções auxiliares e utilitários reutilizáveis
│
├── data/ # Camada de dados
│ ├── models/ # Estruturas de dados (entidades do app)
│ └── services/ # Acesso a APIs, autenticação e persistência remota/local
│
├── presentation/ # Camada de apresentação (UI + lógica de estado)
│ ├── providers/ # Gerenciamento de estado com Provider
│ ├── screens/ # Telas organizadas por funcionalidade
│ └── widgets/ # Componentes visuais reutilizáveis
│
└── main.dart # Ponto de entrada da aplicação
```

## 🧱 Camadas da Arquitetura

O projeto segue uma separação em **três camadas principais**, baseada nos princípios da **Clean Architecture**, porém adaptada neste projeto.

### 1. `core/` — Núcleo compartilhado
Contém recursos **genéricos e reutilizáveis** que não dependem de nenhuma regra de negócio.

**Responsabilidades:**
- Definir tema global (`ThemeData`, cores, tipografia)
- Armazenar funções auxiliares e extensões
- Manter constantes e configurações básicas

**Exemplo:**  
- `AppTheme` define a paleta de cores e estilo visual de todo o app.



### 2. `data/` — Camada de dados
Responsável pela **obtenção e manipulação dos dados**, seja por meio de APIs, autenticação ou armazenamento local.

**Responsabilidades:**
- Fazer chamadas HTTP
- Converter dados JSON em modelos (`models/`)
- Centralizar acesso a fontes de dados (`services/`)

**Observação:**  
O projeto utiliza o termo **`service`** para simplificar a camada de dados, já que o app é de pequeno porte.  
Cada *service* representa uma interface direta com uma fonte de dados (por exemplo, API de receitas, autenticação ou perfil de usuário).


### 3. `presentation/` — Camada de apresentação
Camada responsável pela **interface com o usuário** e pela **lógica de estado** que conecta UI e dados.

**Responsabilidades:**
- Gerenciar estado com o pacote [`provider`](https://pub.dev/packages/provider)
- Exibir telas e componentes visuais
- Reagir a alterações no estado da aplicação

**Estrutura interna:**
- `providers/` → classes que controlam o estado e chamam os *services*  
- `screens/` → telas completas organizadas por funcionalidade  
- `widgets/` → componentes reutilizáveis  


## 🧩 Fluxo de Dados

O fluxo segue o padrão **unidirecional**, garantindo previsibilidade e baixo acoplamento:

1. O **usuário** interage com a UI.  
2. O **provider** reage à ação, chama o **service** correspondente.  
3. O **service** comunica-se com a API e retorna os dados.  
4. O **provider** atualiza o estado, notificando a UI.

## 🧰 Gerenciamento de Estado

O projeto utiliza o pacote [`provider`](https://pub.dev/packages/provider), por ser **leve, reativo e de fácil integração** com o Flutter.

**Justificativa de escolha:**
- Simples de implementar em projetos pequenos
- Mantém a separação clara entre UI e lógica
- Evita sobrecarga desnecessária (como com o padrão BLoC)
- Facilita testes unitários e legibilidade do código
- A utilização de BLoC causaria excesso de *boilerplate* e complexidade desnecessária (*overkill*)

## 🧭 Princípios seguidos

- **Separação de responsabilidades:** cada camada cumpre um papel único.  
- **Baixo acoplamento:** as camadas conhecem apenas a imediatamente inferior.  
- **Alta coesão:** arquivos e classes tratam de um único propósito.  
- **Escalabilidade:** permite evoluir o app sem comprometer a estrutura existente.  

## ✅ Conclusão

A arquitetura foi planejada para ser **simples, modular e escalável**, aplicando princípios da Clean Architecture.  

---
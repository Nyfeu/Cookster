const mongoose = require('mongoose');
require('dotenv').config();

// Modelo com ingredientes genéricos
const IngredientSchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: true, 
    trim: true,
    lowercase: true,  // Padroniza em minúsculas
    enum: [           // Lista de ingredientes padronizados
      'farinha de trigo', 'açúcar', 'ovos', 'leite', 'óleo',
      'fermento', 'chocolate em pó', 'sal', 'manteiga', 'frango',
      'alho', 'cebola', 'limão', 'azeite', 'pão', 'queijo',
      'tomate', 'alface', 'cenoura', 'arroz', 'feijão', 'batata',
      'carne bovina', 'peixe', 'ervas', 'iogurte', 'frutas', 'cogumelos'
    ]
  },
  quantity: { type: Number, min: 0, default: null },
  unit: { 
    type: String, 
    enum: ['g', 'kg', 'ml', 'L', 'colher', 'xícara', 'unidade', 'pitada', null],
    default: null 
  },
  note: { type: String, trim: true, maxlength: 50, default: null }
}, { _id: false });

const RecipeSchema = new mongoose.Schema({
  user_id: { 
    type: String,
    required: true,
    index: true
  },
  name: { 
    type: String, 
    required: true,
    trim: true,
    maxlength: 120
  },
  description: {
    type: String,
    trim: true,
    maxlength: 500
  },
  prep_time: {
    type: Number,
    min: 0,
    default: 0
  },
  cook_time: {
    type: Number,
    min: 0,
    default: 0
  },
  total_time: {
    type: Number,
    min: 0,
    default: 0
  },
  servings: {
    type: Number,
    min: 1,
    default: 1
  },
  tags: [{
    type: String,
    trim: true,
    lowercase: true,
    maxlength: 30
  }],
  steps: [{
    type: String,
    trim: true,
    required: true,
    minlength: 10
  }],
  ingredients: [IngredientSchema],
  utensils: [{
    type: String,
    trim: true,
    lowercase: true,
    maxlength: 30
  }],
  image_url: {
    type: String,
    trim: true,
    default: null
  },
  created_at: {
    type: Date,
    default: Date.now
  },
  updated_at: {
    type: Date,
    default: Date.now
  }
});

RecipeSchema.pre('save', function(next) {
  this.total_time = this.prep_time + this.cook_time;
  this.updated_at = new Date();
  
  // Padroniza ingredientes
  this.ingredients.forEach(ing => {
    ing.name = ing.name.toLowerCase().trim();
  });
  
  next();
});

const Recipe = mongoose.model('Recipe', RecipeSchema);

// Função para popular o banco
async function seedDatabase() {
  try {

    const dbUser = process.env.DB_USER;
    const dbPassword = process.env.DB_PASS;
    const mongoURI = `mongodb+srv://${dbUser}:${dbPassword}@cluster0.fbrwz1j.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0`;

    await mongoose.connect(mongoURI);
    console.log('Conectado ao MongoDB Atlas...');

    await Recipe.deleteMany({});
    console.log('Coleção limpa...');

    const sampleRecipes = [
      {
        user_id: new mongoose.Types.ObjectId(),
        name: "Bolo Simples de Chocolate",
        description: "Receita básica de bolo de chocolate para iniciantes",
        prep_time: 20,
        cook_time: 40,
        servings: 8,
        tags: ["sobremesa", "fácil", "chocolate"],
        steps: [
          "Pré-aquecer forno a 180°C",
          "Misturar ingredientes secos em uma tigela",
          "Adicionar ingredientes líquidos e misturar até homogêneo",
          "Assar por 40 minutos e deixar esfriar"
        ],
        ingredients: [
          { name: "farinha de trigo", quantity: 300, unit: "g" },
          { name: "açúcar", quantity: 200, unit: "g" },
          { name: "chocolate em pó", quantity: 80, unit: "g", note: "achocolatado" },
          { name: "ovos", quantity: 3, unit: "unidade" },
          { name: "leite", quantity: 250, unit: "ml" },
          { name: "óleo", quantity: 120, unit: "ml", note: "vegetal" },
          { name: "fermento", quantity: 1, unit: "colher" }
        ],
        utensils: ["forma", "batedeira", "tigelas"],
        image_url: "https://exemplo.com/bolo-chocolate.jpg"
      },
      {
        user_id: new mongoose.Types.ObjectId(),
        name: "Frango Grelhado com Ervas",
        description: "Peito de frango temperado com ervas e limão",
        prep_time: 15,
        cook_time: 20,
        servings: 4,
        tags: ["jantar", "proteína", "saudável"],
        steps: [
          "Temperar o frango com ervas e limão",
          "Deixar marinar por 30 minutos",
          "Grelhar por 10 minutos de cada lado",
          "Descansar antes de servir"
        ],
        ingredients: [
          { name: "frango", quantity: 500, unit: "g", note: "peito" },
          { name: "alho", quantity: 3, unit: "unidade", note: "amassado" },
          { name: "limão", quantity: 1, unit: "unidade", note: "suco" },
          { name: "azeite", quantity: 2, unit: "colher" },
          { name: "ervas", quantity: 1, unit: "colher", note: "frescas" }
        ],
        utensils: ["grelha", "tábua", "faca"],
        image_url: "https://exemplo.com/frango-grelhado.jpg"
      },
      {
        user_id: new mongoose.Types.ObjectId(),
        name: "Salada Completa",
        description: "Salada nutritiva com diversos vegetais",
        prep_time: 15,
        cook_time: 0,
        servings: 2,
        tags: ["saudável", "rápido", "vegetariano"],
        steps: [
          "Lavar e cortar todos os vegetais",
          "Misturar em uma tigela grande",
          "Preparar molho a gosto",
          "Servir fresco"
        ],
        ingredients: [
          { name: "alface", quantity: 1, unit: "unidade", note: "romana" },
          { name: "tomate", quantity: 2, unit: "unidade", note: "cereja" },
          { name: "cenoura", quantity: 1, unit: "unidade", note: "ralada" },
          { name: "queijo", quantity: 100, unit: "g", note: "parmesão" }
        ],
        utensils: ["tigela", "faca", "ralador"],
        image_url: "https://exemplo.com/salada-completa.jpg"
      },
      {
        user_id: new mongoose.Types.ObjectId(),
        name: "Arroz Cremoso de Cogumelos",
        description: "Arroz estilo risoto com cogumelos frescos",
        prep_time: 10,
        cook_time: 25,
        servings: 4,
        tags: ["principal", "vegetariano", "cremoso"],
        steps: [
          "Refogar cebola e alho em azeite",
          "Adicionar arroz e tostar levemente",
          "Cozinhar adicionando caldo aos poucos",
          "Acrescentar cogumelos no final"
        ],
        ingredients: [
          { name: "arroz", quantity: 400, unit: "g", note: "arbóreo" },
          { name: "cebola", quantity: 1, unit: "unidade", note: "picada" },
          { name: "alho", quantity: 2, unit: "unidade" },
          { name: "cogumelos", quantity: 200, unit: "g", note: "frescos" }
        ],
        utensils: ["panela", "colher", "tábua"],
        image_url: "https://exemplo.com/arroz-cogumelos.jpg"
      },
      {
        user_id: new mongoose.Types.ObjectId(),
        name: "Smoothie Energético",
        description: "Bebida refrescante com frutas e iogurte",
        prep_time: 5,
        cook_time: 0,
        servings: 2,
        tags: ["café da manhã", "rápido", "frutas"],
        steps: [
          "Descascar e cortar as frutas",
          "Colocar todos os ingredientes no liquidificador",
          "Bater até obter consistência homogênea",
          "Servir imediatamente"
        ],
        ingredients: [
          { name: "frutas", quantity: 2, unit: "xícara", note: "mistura tropical" },
          { name: "iogurte", quantity: 200, unit: "ml", note: "natural" },
          { name: "leite", quantity: 100, unit: "ml" }
        ],
        utensils: ["liquidificador", "copos"],
        image_url: "https://exemplo.com/smoothie-energetico.jpg"
      }
    ];

    await Recipe.insertMany(sampleRecipes);
    console.log(`${sampleRecipes.length} receitas inseridas!`);

    // Criar índice de texto
    await Recipe.collection.createIndex({
      name: 'text',
      'ingredients.name': 'text',
      tags: 'text'
    }, {
      name: 'recipe_search_index',
      weights: {
        name: 10,
        'ingredients.name': 8,
        tags: 5
      }
    });
    console.log('Índice de texto criado!');

  } catch (err) {
    console.error('Erro:', err);
  } finally {
    await mongoose.disconnect();
  }
}

seedDatabase();
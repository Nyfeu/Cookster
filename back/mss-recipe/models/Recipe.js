const mongoose = require('mongoose');

const IngredientSchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: true, 
    trim: true,
    lowercase: true
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
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
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

// Middleware para calcular campos antes de salvar
RecipeSchema.pre('save', function(next) {
  this.total_time = this.prep_time + this.cook_time;
  this.updated_at = new Date();
  next();
});

// Índice para busca textual
RecipeSchema.index({
  name: 'text',
  'ingredients.name': 'text',
  tags: 'text'
}, {
  name: 'search_index',
  weights: {
    name: 10,
    'ingredients.name': 8,
    tags: 5
  }
});

module.exports = mongoose.model('Recipe', RecipeSchema);
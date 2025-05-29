const mongoose = require('mongoose')

const IngredientSchema = new mongoose.Schema({
  userId: { type: String, required: true },  // Id do usuário dono do ingrediente
  nome: { type: String, required: true },
  quantidade: { type: Number, default: 1 },
  unidade: { type: String },
  dataValidade: { type: Date },
  categoria: { type: String }
}, { timestamps: true })

module.exports = mongoose.model('pantry', IngredientSchema)

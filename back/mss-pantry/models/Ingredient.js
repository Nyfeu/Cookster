const mongoose = require('mongoose')

const IngredientSchema = new mongoose.Schema({
  nome: { type: String, required: true },
  categoria: { type: String, required: true }
})

const PantrySchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  ingredientes: [IngredientSchema]
}, { timestamps: true })

module.exports = mongoose.model('pantry', PantrySchema)

const mongoose = require('mongoose');

const RecipeSchema = new mongoose.Schema({
  user_id: { type: String, required: true },
  name: { type: String, required: true },
  description: String,
  prep_time: Number,
  cook_time: Number,
  servings: Number,
  tags: [String],
  steps: [String],
  ingredients: [
    {
      ingredient_id: { type: String, required: true },
      name: { type: String, required: true },
      quantity: { type: Number, default: null },
      unit: { type: String, default: null },
      notes: { type: String, default: null }
    }
  ],
  utensils: [String],
  image_url: String
});

module.exports = mongoose.model('Recipe', RecipeSchema);

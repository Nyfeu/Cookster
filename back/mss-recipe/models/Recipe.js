const mongoose = require('mongoose');

const RecipeSchema = new mongoose.Schema({
  user_id: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  ingredients: {
    type: [String],
    required: true
  }
});

const Recipe = mongoose.model('Recipe', RecipeSchema);

module.exports = Recipe;

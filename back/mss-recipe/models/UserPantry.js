const mongoose = require('mongoose');

const UserPantrySchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    unique: true
  },
  ingredients: {
    type: [String],
    default: []
  }
});

module.exports = mongoose.model('UserPantry', UserPantrySchema);

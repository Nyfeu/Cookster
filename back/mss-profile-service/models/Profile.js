const mongoose = require('mongoose');

const UserProfileSchema = new mongoose.Schema({
    userId: { 
        type: String,
        ref: 'users',
        required: true,
        unique: true
    },
    bio: {
        type: String,
        default: ''
    },
    profissao: {
        type: String,
        default: ''
    },
    fotoPerfil: {
        type: String, 
        default: ''
    },
});

module.exports = mongoose.model('profile', UserProfileSchema);
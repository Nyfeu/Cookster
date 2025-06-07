const mongoose = require('mongoose');

const UserProfileSchema = new mongoose.Schema({
    userId: { 
        type: String,
        default:  ''
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
    email: {
        type: String,
        default: ''
    },
    name: {
        type: String,
        default: ''
    },
    descricao: {
        type: String,
        default: ''
    }
});

module.exports = mongoose.model('profile', UserProfileSchema);
const mongoose = require('mongoose')

const User = mongoose.model('User', {
    id: String,
    name: String,
    email: String,
    password: String
})

module.exports = User
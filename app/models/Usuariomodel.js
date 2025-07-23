const mongoose = require('mongoose');

const UsuarioSchema = new mongoose.Schema({
    nombre: {
        type: String,
        required: true,
        trim: true
    },
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true,
        match: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    },
    pass: {
        type: String,
        required: true
    },
    rol: {
        type: String,
        enum: ['admin', 'cliente', 'gerente'],
        default: 'cliente'
    }
}, { timestamps: true });

module.exports = mongoose.model('Usuario', UsuarioSchema);

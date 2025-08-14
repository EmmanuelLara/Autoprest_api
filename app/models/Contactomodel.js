const mongoose = require('mongoose');
const contactSchema = new mongoose.Schema( {
    Servicio: {
        type: String,
        required: true
    },
    Nombre: {
        type: String,
        required: true
    },
    Mensaje: {
        type: String,
        required: true
    }},
    {
        timestamps: true
    });
    module.exports = mongoose.model('Contacto', contactSchema);

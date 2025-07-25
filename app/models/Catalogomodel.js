// models/catalogomodel.js
const mongoose = require('mongoose');

const catalogoSchema = new mongoose.Schema({
    Marca: String,
    Modelo: String,
    Anio: Number,
    Tipo: String,
    Condicion: String,
    Transmision: String,
    Combustible: String,
    Kilometraje: Number,
    Color: String,
    Imagen: String,
    Precio: Number,
    Descripcion: String,
    Accesorios: [String]
}, {
    timestamps: true
});

module.exports = mongoose.model('Catalogo', catalogoSchema);

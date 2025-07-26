// models/comprasmodel.js
const mongoose = require('mongoose');

const VentaSchema = new mongoose.Schema({
    vehiculo_id: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Catalogo'
    },
    comprador_nombre: {
        type: String,
        required: true
    },
    comprador_apellidos: {
        type: String,
        required: true
    },
    comprador_telefono: {
        type: String,
        required: true
    },
    comprador_correo: {
        type: String,
        required: true
    },
    Marca: String,
    Modelo: String,
    Anio: Number,
    Tipo: String,
    Condicion: String,
    Transmision: String,
    Combustible: String,
    Kilometraje: Number,
    NombreVendedor: String,
    TelefonoVendedor: String,
    Color: String,
    Imagen: String,
    Precio: Number,
    PrecioVenta: Number,
    Descripcion: String,
    Accesorios: [String],
    fechaVenta: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Venta', VentaSchema);

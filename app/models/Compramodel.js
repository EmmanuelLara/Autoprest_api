const mongoose = require('mongoose');

const compraSchema = new mongoose.Schema({
    NombreVendedor: {
        type: String,
        required: true,
        trim: true
    },
    TelefonoVendedor: {
        type: String,
        required: true,
        match: /^\d{10,20}$/ 
    },
    VIN: {
    type: String,
    required: true,
    unique: true,
    uppercase: true,
    match: /^[A-HJ-NPR-Z0-9]{17}$/, // patrón estándar VIN
},

    Marca: {
        type: String,
        required: true,
        trim: true
    },
    Modelo: {
        type: String,
        required: true,
        trim: true
    },
    Anio: {
        type: Number,
        required: true,
        min: 1900,
        max: new Date().getFullYear() + 1
    },
    Tipo: {
        type: String,
        required: true,
        trim: true
    },
    Condicion: {
        type: String,
        required: true,
        trim: true
    },
    Transmision: {
        type: String,
        required: true,
        trim: true
    },
    Combustible: {
        type: String,
        required: true,
        trim: true
    },
    Kilometraje: {
        type: Number,
        required: true,
        min: 0
    },
    Color: {
        type: String,
        required: true,
        trim: true
    },
    Imagen: {
        type: String,
        required: true
    },
    Precio: {
        type: Number,
        required: true,
        min: 0.01
    },
    Descripcion: {
        type: String,
        required: true
    },
    Accesorios: {
        type: String,
        default: ''
    },
    Estado: {
        type: String,
        enum: ['pendiente', 'aprobado', 'rechazado'],
        default: 'pendiente'
    },
    UsuarioID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Cliente',
        required: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Compra', compraSchema);

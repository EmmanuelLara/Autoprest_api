const mongoose = require('mongoose');

const compraSchema = new mongoose.Schema({
    NombreVendedor: {
        type: String,
        required: true,
        trim: true,
        match: /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/, // Solo letras, espacios y acentos
        validate: {
            validator: function(v) {
                return !/[%&$#@!*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(v);
            },
            message: 'El nombre no puede contener caracteres especiales'
        }
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
        trim: true,
        match: /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/, // Solo letras, espacios y acentos
        validate: {
            validator: function(v) {
                return !/[%&$#@!*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(v);
            },
            message: 'La marca no puede contener caracteres especiales'
        }
    },
    Modelo: {
        type: String,
        required: true,
        trim: true,
        match: /^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\-]+$/, // Letras, números, espacios, guiones
        validate: {
            validator: function(v) {
                return !/[%&$#@!*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(v);
            },
            message: 'El modelo no puede contener caracteres especiales'
        }
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
        trim: true,
        match: /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/, // Solo letras, espacios y acentos
        validate: {
            validator: function(v) {
                return !/[%&$#@!*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(v);
            },
            message: 'El tipo no puede contener caracteres especiales'
        }
    },
    Condicion: {
        type: String,
        required: true,
        trim: true,
        match: /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/, // Solo letras, espacios y acentos
        validate: {
            validator: function(v) {
                return !/[%&$#@!*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(v);
            },
            message: 'La condición no puede contener caracteres especiales'
        }
    },
    Transmision: {
        type: String,
        required: true,
        trim: true,
        match: /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/, // Solo letras, espacios y acentos
        validate: {
            validator: function(v) {
                return !/[%&$#@!*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(v);
            },
            message: 'La transmisión no puede contener caracteres especiales'
        }
    },
    Combustible: {
        type: String,
        required: true,
        trim: true,
        match: /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/, // Solo letras, espacios y acentos
        validate: {
            validator: function(v) {
                return !/[%&$#@!*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(v);
            },
            message: 'El combustible no puede contener caracteres especiales'
        }
    },
    Kilometraje: {
        type: Number,
        required: true,
        min: 0
    },
    Color: {
        type: String,
        required: true,
        trim: true,
        match: /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/, // Solo letras, espacios y acentos
        validate: {
            validator: function(v) {
                return !/[%&$#@!*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(v);
            },
            message: 'El color no puede contener caracteres especiales'
        }
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
        required: true,
        trim: true,
        validate: {
            validator: function(v) {
                // Permitir letras, números, espacios, comas, puntos, acentos y algunos caracteres básicos
                return /^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s,.\-()]+$/.test(v);
            },
            message: 'La descripción solo puede contener letras, números, espacios, comas, puntos, guiones y paréntesis'
        }
    },
    Accesorios: {
        type: String,
        required: true,
        trim: true,
        validate: {
            validator: function(v) {
                // Permitir letras, números, espacios, comas, puntos, acentos y algunos caracteres básicos
                return /^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s,.\-()]+$/.test(v);
            },
            message: 'Los accesorios solo pueden contener letras, números, espacios, comas, puntos, guiones y paréntesis'
        }
    },
    Estado: {
        type: String,
        enum: ['pendiente', 'aprobado', 'rechazado', 'vendido'],
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


const Compra = require('../models/Compramodel');

function agregarCompra(req, res) {
    if (!req.user) {
        return res.status(401).json({ mensaje: 'No autorizado' });
    }

    if (!req.file) {
        return res.status(400).json({ mensaje: 'Imagen requerida' });
    }

    // Validar que todos los campos requeridos estén presentes
    const camposRequeridos = ['VIN', 'Marca', 'Modelo', 'Anio', 'Tipo', 'Condicion', 'Transmision', 'Combustible', 'Kilometraje', 'Color', 'Precio', 'Descripcion', 'Accesorios'];
    const camposFaltantes = camposRequeridos.filter(campo => !req.body[campo] || req.body[campo].toString().trim() === '');
    
    if (camposFaltantes.length > 0) {
        return res.status(400).json({ 
            mensaje: 'Campos requeridos faltantes', 
            camposFaltantes: camposFaltantes 
        });
    }

    // Validar caracteres especiales en campos de texto
    const caracteresInvalidos = /[%&$#@!*()_+\-=\[\]{};':"\\|.<>\/?]/;
    const camposTexto = ['Marca', 'Modelo', 'Tipo', 'Condicion', 'Transmision', 'Combustible', 'Color'];
    const camposDescriptivos = ['Descripcion', 'Accesorios'];
    
    // Validar campos de texto normales
    for (const campo of camposTexto) {
        if (req.body[campo] && caracteresInvalidos.test(req.body[campo])) {
            return res.status(400).json({
                mensaje: 'Datos inválidos',
                error: `El campo ${campo} no puede contener caracteres especiales como %&$#@!*()_+-=[]{};':"\\|.<>/?`
            });
        }
    }
    
    // Validar campos descriptivos (permiten comas, acentos, puntos, guiones, paréntesis)
    for (const campo of camposDescriptivos) {
        if (req.body[campo] && !/^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s,.\-()]+$/.test(req.body[campo])) {
            return res.status(400).json({
                mensaje: 'Datos inválidos',
                error: `El campo ${campo} solo puede contener letras, números, espacios, comas, puntos, guiones y paréntesis`
            });
        }
    }

    // Validar que el año sea un número válido
    const anio = parseInt(req.body.Anio);
    if (isNaN(anio) || anio < 1900 || anio > new Date().getFullYear() + 1) {
        return res.status(400).json({
            mensaje: 'Datos inválidos',
            error: 'El año debe ser un número válido entre 1900 y ' + (new Date().getFullYear() + 1)
        });
    }

    // Validar que el kilometraje sea un número válido
    const kilometraje = parseInt(req.body.Kilometraje);
    if (isNaN(kilometraje) || kilometraje < 0) {
        return res.status(400).json({
            mensaje: 'Datos inválidos',
            error: 'El kilometraje debe ser un número válido mayor o igual a 0'
        });
    }

    // Validar que el precio sea un número válido
    const precio = parseFloat(req.body.Precio);
    if (isNaN(precio) || precio <= 0) {
        return res.status(400).json({
            mensaje: 'Datos inválidos',
            error: 'El precio debe ser un número válido mayor a 0'
        });
    }

    const rutaImagen = `/uploads/${req.file.filename}`;

    const nuevaCompra = new Compra({
        ...req.body,
        Imagen: rutaImagen,
        NombreVendedor: req.user.nombre,
        TelefonoVendedor: req.user.telefono,
        UsuarioID: req.user._id
    });

    nuevaCompra.save()
        .then(info => {
            res.status(200).json({
                mensaje: 'Compra guardada correctamente',
                info
            });
        })
        .catch(error => {
            res.status(500).json({
                mensaje: `Error al guardar: ${error.message}`
            });
        });
}



module.exports = {
    agregarCompra
};

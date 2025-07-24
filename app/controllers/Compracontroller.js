// controllers/compraController.js
const Compra = require('../models/Compramodel');

async function agregarCompra(req, res) {
    if (!req.user) {
        return res.status(401).json({ mensaje: 'No autorizado' });
    }

    if (!req.file) {
        return res.status(400).json({ mensaje: 'Imagen requerida' });
    }

    const rutaImagen = `/uploads/${req.file.filename}`;

    try {
        const nuevaCompra = new Compra({
            ...req.body,
            Imagen: rutaImagen,
            NombreVendedor: req.user.nombre,
            TelefonoVendedor: req.user.telefono,
            UsuarioID: req.user._id
        });

        const info = await nuevaCompra.save();

        res.status(200).json({
            mensaje: 'Compra guardada correctamente',
            info
        });
    } catch (error) {
        res.status(500).json({
            mensaje: `Error al guardar: ${error.message}`
        });
    }
}

module.exports = {
    agregarCompra
};
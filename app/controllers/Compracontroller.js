// controllers/compraController.js
const Compra = require('../models/Compramodel');

function agregarCompra(req, res) {
    if (!req.user) {
        return res.status(401).json({ mensaje: 'No autorizado' });
    }

    if (!req.file) {
        return res.status(400).json({ mensaje: 'Imagen requerida' });
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

function buscarTodo(req, res) {
    Compra.find({})
        .then(compras => {
            if (compras.length) {
                return res.status(200).send({ Compra: compras });
            }
            return res.status(204).send({ mensaje: 'No hay nada que mostrar' });
        })
        .catch(e => {
            return res.status(404).send({ mensaje: `Error al consultar la información: ${e}` });
        });
}

function buscarJoya(req, res, next) {
    const consulta = {};
    consulta[req.params.key] = req.params.value;

    Compra.find(consulta)
        .then(compras => {
            req.body = req.body || {};
            req.body.Compra = compras || [];
            return next();
        })
        .catch(e => {
            req.body = req.body || {};
            req.body.e = e;
            return next();
        });
}

function mostrandojoyas(req, res) {
    if (req.body.e) {
        return res.status(404).send({ mensaje: `Error al buscar la información: ${req.body.e}` });
    }
    if (!req.body.Compra || !req.body.Compra.length) {
        return res.status(204).send({ mensaje: 'No hay nada que mostrar' });
    }
    return res.status(200).send({ Compra: req.body.Compra });
}

module.exports = {
    agregarCompra,
    buscarTodo,
    buscarJoya,
    mostrandojoyas
};

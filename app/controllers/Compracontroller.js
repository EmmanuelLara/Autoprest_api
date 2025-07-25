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

function buscarTodo(req, res) {
    Compra.find({})
        .then(Compra => {
            if(Compra.length){
               return  res.status(200).send({Compra});
            }
            return res.status(204).send({mensaje: 'No hay nada  que mostrando'});
           
        })
        .catch(e => {
           
            return res.status(404).send({mensaje: `Error al consultar la informacion ${e}`});

        });
     
}
function buscarJoya(req, res, next) {
    var consulta = {};
    consulta[req.params.key] = req.params.value;
 
    
    Compra.find(consulta)
    .then(Compra => {
        if (!Compra || !Compra.length) {
            req.body = req.body || {}; // Asegurarse de que req.body existe
            req.body.Compra = [];
            return next();
        }
        req.body = req.body || {}; // Asegurarse de que req.body existe
        req.body.Compra = Compra;
        return next();
    })
    .catch(e => {
        req.body = req.body || {}; // Asegurarse de que req.body existe
        req.body.e = e;
        return next();
    });
}

function mostrandojoyas(req, res) {
    if (req.body.e)return res.status(404).send({mensaje:`Error al buscar la informacion ${req.body.e}`})
    if (!req.body.Compra.length) return res.status(204).send({mensaje:"no hay nada que mostar"})
    let Compra = req.body.Compra
    return res.status(200).send({Compra})

        }



module.exports = {
    agregarCompra, 
    buscarTodo,
    buscarJoya,
    mostrandojoyas
};
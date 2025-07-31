const contacto = require('../models/Contactomodel');

function agregarContacto(req, res) {
    const nuevoContacto = new contacto({
        ...req.body
    });

    nuevoContacto.save()
        .then(info => {
            res.status(200).json({
                mensaje: 'Contacto guardado correctamente',
                info
            });
        })  
        .catch(error => {
            res.status(404).json({
                mensaje: `Error al guardar: ${error.message}`
            });
        });
}
function mostrarContacto(req, res) {
    contacto.find()
        .then(contactos => {
            res.status(200).json({
                mensaje: 'Contactos obtenidos correctamente',
                contactos
            });
        })
        .catch(error => {
            res.status(404).json({
                mensaje: `Error al obtener contactos: ${error.message}`
            });
        });
}
module.exports = {
    agregarContacto
    , mostrarContacto
};







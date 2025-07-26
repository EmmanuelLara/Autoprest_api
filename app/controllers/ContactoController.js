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
module.exports = {
    agregarContacto
};







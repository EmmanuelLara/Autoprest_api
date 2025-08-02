
const Catalogo = require('../models/Catalogomodel');

function mostrarCatalogo(req, res) {
    Catalogo.find()
        .then(vehiculos => {
            if (!vehiculos || vehiculos.length === 0) {
                return res.status(204).json({ mensaje: 'No hay vehículos disponibles en el catálogo.' });
            }

            res.status(200).json({ vehiculos });
        })
        .catch(error => {
            console.error('Error al obtener vehículos:', error);
            res.status(500).json({
                mensaje: 'Error al cargar el catálogo',
                error: error.message
            });
        });
}

module.exports = {
    mostrarCatalogo
   
};

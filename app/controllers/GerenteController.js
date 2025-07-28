const fs = require('fs');
const path = require('path');
const Compra = require('../models/Compramodel');
const Catalogo = require('../models/Catalogomodel'); // Asegúrate de importarlo

// Obtener todos los vehículos pendientes
function obtenerPendientes(req, res) {
    Compra.find({ Estado: 'pendiente' })
        .then(vehiculos => res.status(200).json({ success: true, vehiculos }))
        .catch(() => res.status(500).json({ success: false, message: 'Error al obtener pendientes' }));
}

// Aprobar un vehículo
function aprobarVehiculo(req, res) {
    const { id } = req.params;

    Compra.findById(id)
        .then(vehiculo => {
            if (!vehiculo) {
                return res.status(404).json({ success: false, message: 'Vehículo no encontrado' });
            }

            vehiculo.Estado = 'aprobado';
            return vehiculo.save().then(() => {
             const comision = vehiculo.Precio * 0.15;
const precioConComision = vehiculo.Precio + comision;

const nuevoCatalogo = new Catalogo({
    Marca: vehiculo.Marca,
    Modelo: vehiculo.Modelo,
    Anio: vehiculo.Anio,
    Tipo: vehiculo.Tipo,
    Condicion: vehiculo.Condicion,
    Transmision: vehiculo.Transmision,
    Combustible: vehiculo.Combustible,
    Kilometraje: vehiculo.Kilometraje,
    Color: vehiculo.Color,
    Imagen: vehiculo.Imagen,
    Precio: vehiculo.Precio, // original
    PrecioVenta: precioConComision, // con comisión incluida
    Descripcion: vehiculo.Descripcion,
    Accesorios: vehiculo.Accesorios
});


                return nuevoCatalogo.save().then(() =>
                    res.status(200).json({ 
                        success: true, 
                        message: 'Vehículo aprobado y agregado al catálogo con comisión'
                    })
                );
            });
        })
        .catch(error => {
            console.error(error);
            res.status(500).json({ success: false, message: 'No se pudo aprobar y enviar al catálogo' });
        });
}

// Rechazar vehículo por ID o por otro campo
function rechazarVehiculo(req, res) {
    let vehiculoPromise;

    if (req.params.id) {
        vehiculoPromise = Compra.findById(req.params.id);
    } else if (req.params.key && req.params.value) {
        const query = {};
        query[req.params.key] = req.params.value;
        vehiculoPromise = Compra.findOne(query);
    }

    vehiculoPromise
        .then(vehiculo => {
            if (!vehiculo) {
                return res.status(404).json({ success: false, message: 'Vehículo no encontrado' });
            }

            // Eliminar imagen
            const nombreArchivo = vehiculo.Imagen?.split('/').pop();
            if (nombreArchivo) {
                const rutaImagen = path.join(__dirname, '..', 'public', 'uploads', nombreArchivo);
                if (fs.existsSync(rutaImagen)) {
                    fs.unlinkSync(rutaImagen);
                }
            }

            // Eliminar documento
            return Compra.deleteOne({ _id: vehiculo._id }).then(() =>
                res.status(200).json({ success: true, message: 'Vehículo rechazado y eliminado junto con su imagen' })
            );
        })
        .catch(error => {
            console.error('Error al rechazar/eliminar:', error);
            res.status(500).json({ success: false, message: 'No se pudo rechazar/eliminar el vehículo' });
        });
}

// Buscar vehículo por campo dinámico (como middleware)
function buscarVehiculo(req, res, next) {
    const consulta = {};
    consulta[req.params.key] = req.params.value;

    Compra.find(consulta)
        .then(vehiculos => {
            req.body = req.body || {};
            req.body.vehiculos = vehiculos || [];
            next();
        })
        .catch(error => {
            req.body = req.body || {};
            req.body.error = error;
            next();
        });
}

// Mostrar los vehículos encontrados por el middleware anterior
function mostrarVehiculos(req, res) {
    const { error, vehiculos } = req.body;

    if (error) {
        return res.status(500).json({ success: false, message: `Error al buscar vehículos: ${error}` });
    }

    if (!vehiculos || vehiculos.length === 0) {
        return res.status(204).json({ success: true, message: 'No hay vehículos que mostrar' });
    }

    return res.status(200).json({ success: true, vehiculos });
}

module.exports = {
    obtenerPendientes,
    aprobarVehiculo,
    rechazarVehiculo,
    buscarVehiculo,
    mostrarVehiculos
};

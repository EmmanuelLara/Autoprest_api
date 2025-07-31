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
    const { key, value } = req.params;

    const query = {};
    query[key] = value;

    Compra.findOne(query)
        .then(vehiculo => {
            if (!vehiculo) {
                return res.status(404).json({ success: false, message: 'Vehículo no encontrado' });
            }

            vehiculo.Estado = 'aprobado';
            return vehiculo.save().then(() => {
                const comision = vehiculo.Precio * 0.15;
                const precioConComision = vehiculo.Precio + comision;

                const nuevoCatalogo = new Catalogo({
                    VIN: vehiculo.VIN, // Asegúrate de que el modelo Compra tenga el campo VIN
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
                    Precio: vehiculo.Precio,
                    PrecioVenta: precioConComision,
                    Descripcion: vehiculo.Descripcion,
                    Accesorios: vehiculo.Accesorios
                });

                return nuevoCatalogo.save().then(() => {
                    res.status(200).json({ 
                        success: true, 
                        message: 'Vehículo aprobado y agregado al catálogo con comisión' 
                    });
                });
            });
        })
        .catch(error => {
            console.error(error);
            res.status(500).json({ success: false, message: 'Error al aprobar el vehículo' });
        });
}


// RECHAZAR vehículo por cualquier campo (ej. VIN)
function rechazarVehiculo(req, res) {
    const { key, value } = req.params;

    const query = {};
    query[key] = value;

    Compra.findOne(query)
        .then(vehiculo => {
            if (!vehiculo) {
                return res.status(404).json({ success: false, message: 'Vehículo no encontrado' });
            }

            // Eliminar imagen del servidor
            const nombreArchivo = vehiculo.Imagen?.split('/').pop();
            if (nombreArchivo) {
                const rutaImagen = path.join(__dirname, '..', 'public', 'uploads', nombreArchivo);
                if (fs.existsSync(rutaImagen)) {
                    fs.unlinkSync(rutaImagen);
                }
            }

            // Eliminar documento de MongoDB
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

// Mostrar todos los vehículos sin filtros
function mostrarTodosVehiculos(req, res) {
    Compra.find({})
        .then(vehiculos => {
            if (!vehiculos || vehiculos.length === 0) {
                return res.status(204).json({ success: true, message: 'No hay vehículos que mostrar' });
            }
            return res.status(200).json({ success: true, vehiculos });
        })
        .catch(error => {
            console.error('Error al obtener todos los vehículos:', error);
            res.status(500).json({ success: false, message: 'Error al obtener todos los vehículos' });
        });
}

module.exports = {
    obtenerPendientes,
    aprobarVehiculo,
    rechazarVehiculo,
    buscarVehiculo,
    mostrarVehiculos,
    mostrarTodosVehiculos
};

const fs = require('fs');
const path = require('path');
const Compra = require('../models/Compramodel');

// Obtener todos los vehículos pendientes
async function obtenerPendientes(req, res) {
    try {
        const vehiculos = await Compra.find({ Estado: 'pendiente' });
        res.status(200).json({ success: true, vehiculos });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error al obtener pendientes' });
    }
}

// Aprobar un vehículo
async function aprobarVehiculo(req, res) {
    try {
        const { id } = req.params;

        const vehiculo = await Compra.findById(id);
        if (!vehiculo) {
            return res.status(404).json({ success: false, message: 'Vehículo no encontrado' });
        }

        // Cambiar estado a aprobado
        vehiculo.Estado = 'aprobado';
        await vehiculo.save();

        // Enviar al catálogo
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
            Precio: vehiculo.Precio,
            Descripcion: vehiculo.Descripcion,
            Accesorios: vehiculo.Accesorios
        });

        await nuevoCatalogo.save();

        res.status(200).json({ success: true, message: 'Vehículo aprobado y agregado al catálogo' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'No se pudo aprobar y enviar al catálogo' });
    }
}
// Rechazar un vehículo y eliminarlo



// Rechazar vehículo por ID o por otro campo
async function rechazarVehiculo(req, res) {
    try {
        let vehiculo = null;

        if (req.params.id) {
            // Rechazar por ID
            vehiculo = await Compra.findById(req.params.id);
        } else if (req.params.key && req.params.value) {
            // Rechazar por otro campo (ej: Placa, Modelo, etc.)
            const query = {};
            query[req.params.key] = req.params.value;
            vehiculo = await Compra.findOne(query);
        }

        if (!vehiculo) {
            return res.status(404).json({ success: false, message: 'Vehículo no encontrado' });
        }

        // Eliminar imagen del disco
        const nombreArchivo = vehiculo.Imagen?.split('/').pop();
        if (nombreArchivo) {
            const rutaImagen = path.join(__dirname, '..', 'public', 'uploads', nombreArchivo);
            if (fs.existsSync(rutaImagen)) {
                fs.unlinkSync(rutaImagen);
            }
        }

        // Eliminar el documento
        await Compra.deleteOne({ _id: vehiculo._id });

        res.status(200).json({ success: true, message: 'Vehículo rechazado y eliminado junto con su imagen' });
    } catch (error) {
        console.error('Error al rechazar/eliminar:', error);
        res.status(500).json({ success: false, message: 'No se pudo rechazar/eliminar el vehículo' });
    }
}

function buscarVehiculo(req, res, next) {
    const consulta = {};
    consulta[req.params.key] = req.params.value;

    Compra.find(consulta)
        .then(vehiculos => {
            req.body = req.body || {};
            req.body.vehiculos = vehiculos || [];
            return next();
        })
        .catch(error => {
            req.body = req.body || {};
            req.body.error = error;
            return next();
        });
}
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

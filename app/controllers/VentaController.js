
// controllers/ventaController.js
const Catalogo = require('../models/Catalogomodel');
const Venta = require('../models/Ventamodel');

// Registrar una venta
function realizarVenta(req, res) {
    const vehiculo_id = req.params.id || req.body.vehiculo_id;

    if (!vehiculo_id) {
        return res.status(400).json({ mensaje: 'ID del vehículo requerido' });
    }

    Catalogo.findById(vehiculo_id)
        .then(auto => {
            if (!auto) {
                return res.status(404).json({ mensaje: 'Vehículo no encontrado' });
            }

            const {
                comprador_nombre,
                comprador_apellidos,
                comprador_telefono,
                comprador_correo
            } = req.body;

            const nuevaVenta = new Venta({
                vehiculo_id: auto._id,
                comprador_nombre,
                comprador_apellidos,
                comprador_telefono,
                comprador_correo,
                Marca: auto.Marca,
                Modelo: auto.Modelo,
                Anio: auto.Anio,
                Tipo: auto.Tipo,
                Condicion: auto.Condicion,
                Transmision: auto.Transmision,
                Combustible: auto.Combustible,
                Kilometraje: auto.Kilometraje,
                NombreVendedor: auto.NombreVendedor,
                TelefonoVendedor: auto.TelefonoVendedor,
                Color: auto.Color,
                Imagen: auto.Imagen,
                Precio: auto.Precio,
                PrecioVenta: auto.PrecioVenta,
                Descripcion: auto.Descripcion,
                Accesorios: auto.Accesorios
            });

            nuevaVenta.save()
                .then(ventaGuardada => {
                    // Cambiar estado y eliminar del catálogo
                    auto.estado = 'Vendido';
                    auto.save()
                        .then(() => {
                            auto.deleteOne()
                                .then(() => {
                                    res.status(201).json({
                                        mensaje: 'Venta registrada exitosamente',
                                        venta: ventaGuardada
                                    });
                                })
                                .catch(err => {
                                    res.status(500).json({
                                        mensaje: 'Error al eliminar vehículo del catálogo',
                                        error: err.message
                                    });
                                });
                        })
                        .catch(err => {
                            res.status(500).json({
                                mensaje: 'Error al actualizar estado del vehículo',
                                error: err.message
                            });
                        });
                })
                .catch(err => {
                    res.status(500).json({
                        mensaje: 'Error al guardar venta',
                        error: err.message
                    });
                });
        })
        .catch(err => {
            res.status(500).json({
                mensaje: 'Error al buscar vehículo',
                error: err.message
            });
        });
}

// Obtener un vehículo por ID (si lo necesitas en la app)function buscarventa(req, res, next) {
function buscarventa(req, res, next) {
    const consulta = {};
    consulta[req.params.key] = req.params.value;

    Venta.find(consulta)
        .then(ventas => {
            req.body = req.body || {};
            req.body.ventas = ventas || [];
            return next();
        })
        .catch(e => {
            req.body = req.body || {};
            req.body.e = e;
            return next();
        });
}

function mostrarventa(req, res) {
    if (req.body.e) {
        return res.status(404).send({ mensaje: `Error al buscar la información: ${req.body.e}` });
    }
    if (!req.body.ventas || !req.body.ventas.length) {
        return res.status(204).send({ mensaje: 'No hay ventas que mostrar' });
    }
    return res.status(200).send({ ventas: req.body.ventas });
}


module.exports = {
    realizarVenta,
    buscarventa,
    mostrarventa
};

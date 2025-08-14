

const Catalogo = require('../models/Catalogomodel');
const Venta = require('../models/Ventamodel');
const Compra = require('../models/Compramodel');

// Registrar una venta
function realizarVenta(req, res) {
    const key = req.params.key;
    const value = req.params.value;

    if (!key || !value) {
        return res.status(400).json({ mensaje: 'Parámetro de búsqueda inválido' });
    }

    const query = {};
    query[key] = value;

    Catalogo.findOne(query)
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

            // Validar que todos los campos requeridos estén presentes
            if (!comprador_nombre || !comprador_apellidos || !comprador_telefono || !comprador_correo) {
                return res.status(400).json({
                    mensaje: 'Faltan campos requeridos del comprador',
                    campos_requeridos: {
                        comprador_nombre: 'Nombre del comprador',
                        comprador_apellidos: 'Apellidos del comprador',
                        comprador_telefono: 'Teléfono del comprador',
                        comprador_correo: 'Correo electrónico del comprador'
                    },
                    campos_enviados: req.body
                });
            }

            const nuevaVenta = new Venta({
                vehiculo_id: auto._id,
                VIN: auto.VIN,
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
                    // Actualizar estado en catálogo
                    auto.estado = 'Vendido';
                    auto.save()
                        .then(() => {
                            // Actualizar estado en tabla de compras
                            return Compra.findOneAndUpdate(
                                { VIN: auto.VIN },
                                { Estado: 'vendido' },
                                { new: true }
                            );
                        })
                        .then(() => {
                            // Eliminar del catálogo
                            return auto.deleteOne();
                        })
                        .then(() => {
                            res.status(201).json({
                                mensaje: 'Venta registrada exitosamente',
                                venta: ventaGuardada
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
                    console.error('Error al guardar venta:', err);
                    res.status(500).json({
                        mensaje: 'Error al guardar venta',
                        error: err.message,
                        detalles: 'Verifica que todos los campos requeridos estén presentes y sean válidos'
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

function buscarTodo(req, res) {
    Venta.find({})
        .then(ventas => {
            res.json({ ventas });
        })
        .catch(e => {
            res.status(500).json({ error: 'Error al obtener ventas', detalle: e.message });
        });
}
// Obtener un vehículo por ID (si lo necesitas en la app)function buscarventa(req, res, next) {
function buscarventa(req, res, next) {
    const key = req.params.key.trim();
    const value = req.params.value.trim();
    
    console.log('Buscando venta con:', { key, value });
    
    const consulta = {};
    consulta[key] = value;

    Venta.find(consulta)
        .then(ventas => {
            console.log('Ventas encontradas:', ventas.length);
            req.body = req.body || {};
            req.body.ventas = ventas || [];
            return next();
        })
        .catch(e => {
            console.error('Error al buscar venta:', e);
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
        // Si estamos buscando una venta específica (endpoint con parámetros), devolver 404
        // Si estamos listando ventas en general, devolver 204
        if (req.params.key && req.params.value) {
            return res.status(404).send({ mensaje: 'Venta no encontrada' });
        } else {
            return res.status(204).send({ mensaje: 'No hay ventas que mostrar' });
        }
    }
    return res.status(200).send({ ventas: req.body.ventas });
}


module.exports = {
    realizarVenta,
    buscarventa,
    mostrarventa,
    buscarTodo
};

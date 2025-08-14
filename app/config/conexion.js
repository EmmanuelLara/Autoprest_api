const config = require('./configuracion');
const mongoose = require('mongoose');

module.exports = {
    connection: null,
    connect: () => {
        if(this.connection) return this.connection;
        
        // Asegurar que la URL de la base de datos incluya el nombre correcto
        const dbUrl = config.DB.endsWith('/') ? config.DB + 'Autoprest' : config.DB;
        
        return mongoose.connect(dbUrl, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        })
        .then(() => {
            console.log('✅ Conectado a MongoDB');
            this.connection = mongoose.connection;
            return this.connection;
        })
        .catch(err => {
            console.error('❌ Error de conexión a MongoDB:', err);
            throw err;
        });
    }
};

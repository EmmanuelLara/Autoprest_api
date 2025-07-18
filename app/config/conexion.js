const config = require('./configuracion');
const mongoose = require('mongoose');


module.exports = {
    connection: null,
    connect: () => {
        if(this.connection) return this.connection
       return mongoose.connect(config.DB)
 .then(() => console.log('✅ Conectado a MongoDB'))
.catch(err => console.error('❌ Error de conexión a MongoDB:', err));
    }
            
}

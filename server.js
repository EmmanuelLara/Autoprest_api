const CONFIG = require('./app/config/configuracion');
const app = require('./app/app');
const conexion = require('./app/config/conexion');


conexion.connect();



app.listen(CONFIG.PORT, () => {
  console.log(`Server is running on http://localhost:${CONFIG.PORT}`);
});
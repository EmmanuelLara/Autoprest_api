const multer = require('multer');
const path = require('path');

// Configurar almacenamiento
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'app/public/uploads');
    },
    filename: (req, file, cb) => {
        const nombreUnico = Date.now() + '-' + file.originalname.replace(/\s+/g, '_');
        cb(null, nombreUnico);
    }
});

// Filtro de archivos corregido
const fileFilter = (req, file, cb) => {
    const tiposPermitidos = ['.jpg', '.jpeg', '.png', '.webp'];
    const ext = path.extname(file.originalname).toLowerCase();
    
    // Corrección: 'image/' en minúsculas
    const esMimeValido = file.mimetype.startsWith('image/');
    const esExtensionValida = tiposPermitidos.includes(ext);

    if (esExtensionValida && esMimeValido) {
        cb(null, true);
    } else {
        cb(new Error(`Solo se permiten imágenes (${tiposPermitidos.join(', ')})`));
    }
};

// Configuración de Multer
const upload = multer({
    storage,
    fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5 MB
    }
});

module.exports = {
    upload
};
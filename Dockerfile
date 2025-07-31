# Dockerfile
FROM node:18

# Crear directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar package.json y package-lock.json para instalar dependencias
COPY package*.json ./

# Instalar dependencias del proyecto
RUN npm install

# Copiar el resto de los archivos al contenedor
COPY . .

# Exponer el puerto (ajústalo si usas otro)
EXPOSE 3000

# Comando para iniciar el servidor
CMD ["npm", "run", "dev"]

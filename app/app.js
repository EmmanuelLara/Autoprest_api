const express = require('express');
const app = express();
//const router = require('./routes/joyasRoute');


app.use(express.urlencoded({ extended: false }));
app.use(express.json());

//app.use('/joyas', router);




module.exports = app;


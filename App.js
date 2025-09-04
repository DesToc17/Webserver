const hbs = require('hbs');
const express = require('express')
require('dotenv').config();

const app = express()
const port = process.env.PORT


app.set('view engine', 'hbs');
app.use(express.static('Public'));

hbs.registerPartials(__dirname + '/views/partials', function (err) { });


app.get('/', (req, res) => {
    res.render('home', {
        nombre: 'Juan Manuel',
        titulo: 'Curso node'
    });
})

app.get('/elements', (req, res) => {//La carpeta debe tener el mismo nombre de la carpeta a la cual se 
    //redirige la app
    res.render('elements', {
        nombre: 'Juan Manuel',
        titulo: 'Curso node'
    });
})

app.get('/generic', (req, res) => {//La carpeta debe tener el mismo nombre de la carpeta a la cual se 
    //redirige la app
    res.render('generic', {
        nombre: 'Juan Manuel',
        titulo: 'Curso node'
    });
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})

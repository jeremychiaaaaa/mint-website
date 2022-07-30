const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 8000;

const whiteListRoutes = require('./routes/whiteList')

app.listen(port, () => {
    console.log(`app listens on http://localhost:${port} `)
})

app.use('/api', whiteListRoutes)
app.use(cors())
app.use(express.json());
app.use(express.urlencoded({ extended: false })); //parsing the url string with the query selector
module.exports = app

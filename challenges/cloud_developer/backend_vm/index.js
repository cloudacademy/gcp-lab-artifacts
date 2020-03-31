const express = require('express')
const cors = require('cors')

const app = express()

app.use(cors())

app.get('/', (req, res) => {
    res.json({})
})

app.listen(3000, _ => {
    console.log('Server is listening on port 3000')
})
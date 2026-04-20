const express = require('express');
const { exec } = require('child_process');
const pg = require('pg');
const app = express();

const client = new pg.Client({
    host: 'db',
    database: process.env.POSTGRES_DB,
    user: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    port: 5432,
})
client.connect()

app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    next();
});


app.get('/get-file-list', (req, res) => {
    const args = req.query?.args || '';
    const command = `ls ${args}`;

    exec(command, {cwd: 'node_modules'} ,(error, stdout, stderr) => {
        if (error) {
            res.status(500).send(`Error: ${error.message}`);
            return;
        }
        res.status(200).send({stdout, stderr});
    });
});

app.get('/requests/:sort', async (req, res) => {
    const sort = req.params.sort || '1';
    try {
        const result = await client.query(`SELECT * FROM product ORDER BY ${sort}`);
        console.log('results', result);
        res.send(result);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server error');
    }
});

app.get('/healthcheck', async (req, res) => {
    res.json({status: 'ok'});
});

app.listen(3000, () => console.log('Ping service running on port 3000'));
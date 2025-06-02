const express = require('express');
const app = express();

app.use(express.json());

app.use((req, res) => {

    console.log('📩 Requisição recebida no mss-debug');

    console.log('➡️ Método:', req.method);
    console.log('➡️ Caminho:', req.path);
    console.log('➡️ Headers:', req.headers);
    console.log('➡️ Body:', req.body);

    res.json({
        message: 'Requisição recebida no mss-debug',
        received: {
            method: req.method,
            path: req.path,
            headers: req.headers,
            body: req.body
        }
    });
    
});

const PORT = 7000;
app.listen(PORT, () => {
    console.log(`🟢 MSS-DEBUG (${PORT}): [OK]`);
});

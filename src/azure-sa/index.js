const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const client = require('prom-client');
require('dotenv').config();

client.collectDefaultMetrics();

const { BlobServiceClient, StorageSharedKeyCredential } = require('@azure/storage-blob');

const app = express();
app.disable("x-powered-by");

const PORT = process.env.PORT || 3000;

const upload = multer({ dest: 'uploads/', limits: {
        fileSize: 8000000 // <- Compliant: 8MB
    } });

const sharedKeyCredential = new StorageSharedKeyCredential(
    process.env.AZURE_STORAGE_ACCOUNT_NAME,
    process.env.AZURE_STORAGE_ACCOUNT_KEY
);

const blobServiceClient = new BlobServiceClient(
    `https://${process.env.AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net`,
    sharedKeyCredential
);

const containerClient = blobServiceClient.getContainerClient(process.env.AZURE_CONTAINER_NAME);

const filesDataPath = './filesData.json';

const loadFilesData = () => {
    if (fs.existsSync(filesDataPath)) {
        const data = fs.readFileSync(filesDataPath);
        return JSON.parse(data);
    }
    return [];
};

const saveFilesData = (files) => {
    fs.writeFileSync(filesDataPath, JSON.stringify(files, null, 2));
};

let files = loadFilesData();

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

app.get('/metrics', (req, res) => {
    res.set('Content-Type', client.register.contentType);
    res.end(client.register.metrics());
});

app.post('/upload', upload.single('file'), async (req, res) => {
    const fileName = req.body.note;
    if (!fileName) {
        return res.status(400).send('File name is required.');
    }

    if (req.file) {
        try {
            const blobName = req.file.filename;
            const blockBlobClient = containerClient.getBlockBlobClient(blobName);

            await blockBlobClient.uploadFile(req.file.path);
            fs.unlinkSync(req.file.path); // remove the file locally after upload

            files.push({ name: fileName, key: blobName });
            saveFilesData(files);

            res.status(200).send('File uploaded successfully.');
        } catch (err) {
            console.error('Error uploading file:', err);
            res.status(500).send('Failed to upload file.');
        }
    } else {
        res.status(400).send('No file uploaded.');
    }
});

app.get('/files', (req, res) => {
    res.json(files);
});

app.delete('/files/:key', async (req, res) => {
    const fileKey = req.params.key;

    try {
        const blockBlobClient = containerClient.getBlockBlobClient(fileKey);
        await blockBlobClient.delete();

        files = files.filter(file => file.key !== fileKey);
        saveFilesData(files);

        res.status(200).send('File deleted successfully.');
    } catch (err) {
        console.error('Error deleting file:', err);
        res.status(500).send('Failed to delete file.');
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

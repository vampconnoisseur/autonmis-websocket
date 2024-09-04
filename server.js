const express = require('express');
const AWS = require('aws-sdk');
const WebSocket = require('ws');
const { spawn } = require('child_process');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

const wss = new WebSocket.Server({ port: 6789 });

// AWS configuration route
app.post('/configure-aws', async (req, res) => {
    const { accessKeyId, secretAccessKey, region } = req.body;

    AWS.config.update({
        accessKeyId,
        secretAccessKey,
        region
    });

    try {
        const s3 = new AWS.S3();
        await s3.listBuckets().promise();
        res.json({ success: true, message: 'AWS credentials verified' });
    } catch (error) {
        res.json({ success: false, message: error.message });
    }
});

// WebSocket handling
wss.on('connection', ws => {
    console.log('Client connected');

    ws.on('message', message => {
        const parsedMessage = JSON.parse(message);

        if (parsedMessage.command === 'start-terraform') {
            const { region, username } = parsedMessage;
            console.log(`Starting Terraform process with region: ${region}, username: ${username}`);

            const initialize = spawn('./initialize_terraform.sh', [region, username]);

            initialize.stdout.on('data', data => {
                console.log('Initialization output:', data.toString());
                ws.send(data.toString());
            });

            initialize.stderr.on('data', data => {
                console.error(`Initialization error: ${data}`);
                ws.send(JSON.stringify({ step: "error", status: data.toString() }));
            });

            initialize.on('close', code => {
                if (code === 0) {
                    const terraform = spawn('./apply_terraform.sh', [region, username]);

                    terraform.stdout.on('data', data => {
                        console.log('Terraform output:', data.toString());
                        ws.send(data.toString());
                    });

                    terraform.stderr.on('data', data => {
                        console.error(`Terraform error: ${data}`);
                        ws.send(JSON.stringify({ step: "error", status: data.toString() }));
                    });

                    terraform.on('close', code => {
                        if (code === 0) {
                            ws.send(JSON.stringify({ step: "completed", status: "success" }));
                        } else {
                            ws.send(JSON.stringify({ step: "completed", status: "failed" }));
                        }
                    });
                } else {
                    ws.send(JSON.stringify({ step: "error", status: "Failed to initialize Terraform" }));
                }
            });
        } else if (parsedMessage.command === 'destroy-terraform') {
            const { region, username } = parsedMessage;
            console.log(`Destroying Terraform process with region: ${region}, username: ${username}`);

            const terraform = spawn('./destroy_terraform.sh', [region, username]);

            terraform.stdout.on('data', data => {
                console.log('Terraform destroy output:', data.toString());
                ws.send(data.toString());
            });

            terraform.stderr.on('data', data => {
                console.error(`Terraform destroy error: ${data}`);
                ws.send(JSON.stringify({ step: "error", status: data.toString() }));
            });

            terraform.on('close', code => {
                if (code === 0) {
                    ws.send(JSON.stringify({ step: "completed", status: "success" }));
                } else {
                    ws.send(JSON.stringify({ step: "completed", status: "failed" }));
                }
            });
        }
    });

    ws.on('close', () => {
        console.log('Client disconnected');
    });
});

// HTTP route to trigger Terraform destroy
app.post('/trigger-destroy', (req, res) => {
    const { region, username } = req.body;

    try {
        const destroy = spawn('./destroy_terraform.sh', [region, username]);

        destroy.stdout.on('data', data => {
            console.log('Terraform destroy output:', data.toString());
        });

        destroy.stderr.on('data', data => {
            console.error(`Terraform destroy error: ${data}`);
        });

        destroy.on('close', code => {
            if (code === 0) {
                res.json({ success: true, message: 'Terraform destroy triggered successfully!' });
            } else {
                res.json({ success: false, message: 'Failed to trigger Terraform destroy' });
            }
        });
    } catch (error) {
        console.error('Failed to trigger destroy:', error);
        res.status(500).json({ success: false, message: 'Failed to trigger Terraform destroy' });
    }
});

app.listen(3000, () => {
    console.log('Express server running on port 3000');
});

console.log('WebSocket server running on ws://localhost:6789');
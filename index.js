const http = require('http');
const { URL } = require('url');

exports.handler = async (event) => {
    // Extract region and username from environment variables or from SNS message if needed
    const region = process.env.REGION || 'us-east-1'; // Set default or use from SNS message
    const username = process.env.USERNAME || 'vampconnoisseur'; // Set default or use from SNS message

    // Define the URL for the HTTP request to the Express server
    const expressServerUrl = 'http://18.235.175.234';

    // Use URL constructor instead of url.parse
    const parsedUrl = new URL(expressServerUrl);

    const options = {
        hostname: parsedUrl.hostname,
        port: 3000, // Port 3000 for HTTP
        path: '/trigger-destroy',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
    };

    const requestBody = JSON.stringify({ region, username });

    return new Promise((resolve, reject) => {
        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                if (res.statusCode === 200) {
                    console.log('Successfully triggered destroy:', data);
                    resolve({
                        statusCode: 200,
                        body: JSON.stringify({ success: true, message: 'Terraform destroy triggered successfully!' }),
                    });
                } else {
                    console.error('Failed to trigger destroy:', data);
                    resolve({
                        statusCode: 500,
                        body: JSON.stringify({ success: false, message: 'Failed to trigger Terraform destroy' }),
                    });
                }
            });
        });

        req.on('error', (e) => {
            console.error(`Problem with request: ${e.message}`);
            resolve({
                statusCode: 500,
                body: JSON.stringify({ success: false, message: 'Failed to trigger Terraform destroy' }),
            });
        });

        req.write(requestBody);
        req.end();
    });
};

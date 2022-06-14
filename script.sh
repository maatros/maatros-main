#!/bin/bash
printf '
<html>
<head>
        <title>Terraform</title>
</head>
<body bgcolor=yellow>
        <p style="color: red; text-align: center; font-size: 70px;">Hello World from Pipiline!</p>
</body>
</html>
' >> /var/www/index.html
nohup busybox httpd -f -p 8080 &
#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
#echo "<h2>WebServer</h2><br>Build by Terraform!"  >  /var/www/html/index.html
cat <<- EOF > /var/www/html/index.html
<html>
<head>
        <title>Terraform</title>
</head>
<body bgcolor=yellow>
        <p style="color: red; text-align: center; font-size: 70px;">Hello World from Pipiline!</p>
</body>
</html>
EOF
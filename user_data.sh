#!/bin/bash
cat > index.html <<EOF
<h1>Web Server</h1>
<p>I am the web server running in the ${vpc_name} VPC!</p>
EOF

nohup busybox httpd -f -p "${service_port}" &
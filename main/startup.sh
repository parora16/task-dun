 #!/bin/bash

sudo apt-get update
sudo apt-get install libltdl7
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo docker pull tutum/hello-world
sudo docker run --name hello-world -p 8080 tutum/hello-world
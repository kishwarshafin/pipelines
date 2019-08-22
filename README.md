# UPD Pipelines

Tooling to run the primary, secondary and tertiary pipelines for the UCSC Undiagnosed Pediatric Disease Center

## Install dependencies
To run this program, please install `Make`:
```bash
sudo apt-get update
sudo apt-get install make
```

and `Docker`:
```bash
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
```

To run `Docker` without root privilege:
```bash
sudo groupadd docker
sudo gpasswd -a $USER docker
# now log out and log in once or run:
newgrp docker
```

## Quick Start

Clone this repo, create a directory for data and run a test sample:

```
git clone https://github.com/ucsc-upd/pipelines.git
mkdir data
cd data
make -f ../Makefile primary secondary
```

This will generate a polished genome assembly of the input inside `/data/helen_output/` 

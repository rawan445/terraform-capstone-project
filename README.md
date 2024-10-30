# IaC-capstone-project-1

This project leverages Terraform to provision a robust infrastructure on Alibaba Cloud for hosting a Flask application.

## Infrastructure Overview
This setup includes the following components:
- **Redis Server**: Deployed in a private VSwitch, accessible only by HTTP servers.
- **MySQL Server**: Also in a private VSwitch, securely connecting to HTTP servers.
- **HTTP Servers**: Two instances for processing application requests.
- **Load Balancer**: Distributes incoming traffic across HTTP servers using round-robin routing.
- **Bastion/Runner Server**: A secure SSH access point for managing the infrastructure and serves as a self-hosted runner for Continuous Deployment (CD) workflows..
- **NAT Gateway**: Enables private resources to access the internet.

## Cloud Initialization
Each server is automatically configured using cloud-init scripts upon deployment. 

# terraform-capstone-project

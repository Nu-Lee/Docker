# Dockerfile Guide

This guide provides instructions on how to clone, modify, build, and run the Docker container for the research project, including steps for port configuration and accessing services like CARTA and Jupyter Notebook.

## Dockerfile Update or Modification

1. Clone the repository:  
   `git clone https://github.com/dlskadnr1209/WSCLEAN.git`

2. Navigate into the repository:  
   `cd WSCLEAN`

3. Modify the `Dockerfile` as needed.

4. Build the Docker image (ensure that `piip` and `mwa-reduce` packages are in the same directory):  
   `docker build -t user_name/container_name:tag .`

5. Push the Docker image to Docker Hub (you need to be logged in with a Docker Hub account):  
   `docker login`  
   `docker push user_name/container_name:tag`

## Running Docker on a New Server

1. Run the Docker container with port mapping and directory binding:  
   `docker run -it -p 8888:8888 -p 3002:3002 --name test -v /path/on/host:/root/data/ dlskadnr1209/ryu-lab:v1`

   - This command maps the server ports to the Docker container ports (e.g., 8888 for Jupyter Notebook and 3002 for CARTA).
   - It also binds a directory from the host (`/path/on/host`) to `/root/data/` inside the container.

   **Note:** Ensure that the necessary ports are open on the server by using `ufw` or `iptables` to allow access.

## Server Port Configuration

Open the necessary ports (8888 and 3002) on the server for external access:

- **Using `ufw`:**  
   `sudo ufw allow 8888/tcp`  
   `sudo ufw allow 3002/tcp`

- **Using `iptables`:**  
   `sudo iptables -A INPUT -p tcp --dport 8888 -j ACCEPT`  
   `sudo iptables -A INPUT -p tcp --dport 3002 -j ACCEPT`

## Post-Execution Steps

### 1. SSH Port Forwarding  
   To access Jupyter Notebook and CARTA from your local machine, use the following SSH command for port forwarding:  
   `ssh -L 8888:localhost:8888 -L 3002:localhost:3002 your-server-user@your-server-ip`

### 2. Accessing CARTA  
   Once CARTA is running, it will provide an access URL. Modify the URL to use `localhost` instead of the internal Docker IP.

   - Example (output from CARTA):  
     `CARTA is accessible at http://172.17.0.2:3002/?token=aaaaaaaa-aaaa-aaaa-aaaaa-aaaaaa`

   - Access it locally by changing the IP to `localhost`:  
     `http://localhost:3002/?token=aaaaaaaa-aaaa-aaaa-aaaaa-aaaaaa`

### 3. Running Jupyter Notebook  
   To start Jupyter Notebook inside the container, use the following command without any modifications:  
   `jupyter-notebook --ip=0.0.0.0 --no-browser --allow-root`

## Additional Information

- Ensure that Docker is properly installed and configured on both the server and your local machine.
- Make sure you have the proper SSH access to the server, and that the network configurations allow port forwarding.


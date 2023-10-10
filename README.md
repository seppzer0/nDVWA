# nDVWA — a nginx-served DVWA

nDVWA is a compact Dockerized solution for deploying DVWA with nginx.<br>
Everything is kept in a single container: nginx is pulled as a base image, and DVWA is downloaded directly from it's official git repository.

Additionally, this application offers a few extra SSH configurations between the Docker container and it's host machine.<br>
The SSH connection is established using internal Docker network (which is evident by `docker0` interface and `172.17.0.1` default host address usage in the codebase).<br>
You can opt-out of these configurations via a prompt when starting up the container.

This app was a part of an academic study and had a DoD (Definition-of-Done). The details are presented below.

## Contents

- [nDVWA — a nginx-served DVWA](#ndvwa--a-nginx-served-dvwa)
  - [Contents](#contents)
  - [**Disclaimer**](#disclaimer)
  - [DoD](#dod)
    - [Installing Nginx with Docker](#installing-nginx-with-docker)
    - [Deploying DVWA on Nginx](#deploying-dvwa-on-nginx)
    - [(optional) Establishing Reverse Tunneling to SSH](#optional-establishing-reverse-tunneling-to-ssh)
    - [(optional) Protecting SSH from Nmap Scanning](#optional-protecting-ssh-from-nmap-scanning)
  - [How To Use](#how-to-use)
    - [1. Build (or download) the Docker image](#1-build-or-download-the-docker-image)
    - [2. Create a Docker container](#2-create-a-docker-container)
    - [3. Check deployed DVWA via web-browser](#3-check-deployed-dvwa-via-web-browser)
    - [4. Follow the prompts in Docker container](#4-follow-the-prompts-in-docker-container)

## **Disclaimer**

If you wish to execute **all** of the steps (including SSH configurations), please take into consideration that it might permanently alternate iptables rules on your machine.

Once the SSH configurations are completed, the app flushes `DOCKER` and `INPUT` chains in iptables.

Unless you know what you are doing or able to fix your iptables in case of any issue, it is recommended to run this app in a virtual machine.

Tip: And just in case, run a `sudo iptables -L > ~/default_iptables.txt` before launching the app. That way you'll have a reference to restore your iptables rules if required.

## DoD

### Installing Nginx with Docker

1. install Docker on your system;
2. pull the Nginx Docker image;
3. create a Docker container using the Nginx image;
4. configure the necessary ports for Nginx to operate.

### Deploying DVWA on Nginx

1. download the Damn Vulnerable Web Application (DVWA) package;
2. configure Nginx to serve the DVWA files;
3. verify the successful deployment of DVWA by accessing it through a web browser.

### (optional) Establishing Reverse Tunneling to SSH

1. configure the SSH server to allow reverse tunneling;
2. set up the reverse tunnel by initiating an SSH connection from the Docker container to the SSH server;
3. verify the reverse tunnel connection by accessing the SSH server from the Docker container.

### (optional) Protecting SSH from Nmap Scanning

1. install Nmap for scanning purposes;
2. implement port knocking or port scanning detection mechanisms to prevent unauthorized access attempts;
3. test the implemented measures using Nmap to ensure SSH protection against scanning.

## How To Use

### 1. Build (or download) the Docker image

In the root of the directory, run:

```sh
docker build . -t ndvwa
```

Alternatively, you can download a pre-built image from repository's registry:

```sh
docker pull ghcr.io/seppzer0/ndvwa
```

### 2. Create a Docker container

To create a container, run:

```sh
docker run --rm -it -p 80:80 ndvwa
```

### 3. Check deployed DVWA via web-browser

Using a web-browser, enter `0.0.0.0:80` URL.<br>
When asked for credentials for the first time, use `dvwa` for both login and password.<br>
Then, using UI, create a new database. When asked for credentials again, use `admin` / `password`.

### 4. Follow the prompts in Docker container

Once the container is launched, you will be prompted whether to proceed with SSH configurations or just directly jump into Bash shell.

Keep in mind that in order to establish an SSH connection between a container and a host machine, you need to setup an SSH server on the host machine first.<br>
On a Debian-based machine:

- install `openssh-server` package (use `sudo apt install openssh-server`);
- append `GatewayPorts yes` and `AllowTcpForwarding yes` lines into `/etc/ssh/sshd_config` file;
- restart ssh service with `sudo service ssh restart`.

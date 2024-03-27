# nDVWA

nDVWA is a compact Dockerized solution for deploying DVWA with Nginx.

Everything is kept in a single container: nginx is pulled as a base image, and DVWA is downloaded directly from it's official git repository.

Additionally, this application offers a few extra SSH configurations between the Docker container and it's host machine.

The SSH connection with port knocking protection is established using internal Docker network (which is evident by `docker0` interface and `172.17.0.1` default host address usage in the codebase). You can opt-out of these configurations via a prompt when starting up the container.

This app consist of several key steps. The details are presented below.

## Contents

- [nDVWA](#ndvwa)
  - [Contents](#contents)
  - [**Important**](#important)
  - [How To Use](#how-to-use)
    - [1. Build (or download) the Docker image](#1-build-or-download-the-docker-image)
    - [2. Create a Docker container](#2-create-a-docker-container)
    - [3. Check deployed DVWA via web-browser](#3-check-deployed-dvwa-via-web-browser)
    - [4. Follow the prompts in Docker container](#4-follow-the-prompts-in-docker-container)

## **Important**

> [!IMPORTANT]
> **\- DISCLAIMER \-**
>
>If you wish to execute **all** of the steps (including SSH configurations), please take into consideration that it might permanently alternate iptables rules on your machine.
>
>Once the SSH configurations are complete, the app flushes `DOCKER` and `INPUT` chains in iptables.
>
>Unless you know what you are doing or able to fix your iptables in case of any issue, it is recommended to run this app in a virtual machine (or any other environment that is not someone's primary workspace).

> [!NOTE]
> And just in case, run a `sudo iptables -L > ~/default_iptables.txt` before launching the app. That way you'll have a reference to restore your iptables rules if required.

## How To Use

### 1. Build (or download) the Docker image

In the root of the directory, run:

```sh
docker build . -t ndvwa
```

Alternatively, you can download a pre-built image from the repository's registry:

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

- install `openssh-server` package;
- append `GatewayPorts yes` and `AllowTcpForwarding yes` lines into `/etc/ssh/sshd_config` file;
- restart ssh service.

## Docker Development Environment

---

### Windows Using WSL (Recommended)
**Prerequisites**
|  Name | Version | Installation |
| --- | --- | --- |
| Git | Latest | [Download & Install](https://git-scm.com/downloads) |
| Docker | Latest | [Follow this guide to install](https://docs.docker.com/desktop/install/windows-install/) |
| WSL | Latest | [Follow this guide to install](https://learn.microsoft.com/en-us/windows/wsl/install) |

**Steps to setup**
1. Open VS Code
2. Connect to WSL using Distro (E.G *Ubuntu*)
3. Fork the repository
4. Clone the forked repository
    ```bash
    git clone git@github.com:<username></username>/CircuitVerse.git --recursive
    ```
    - Use `git submodule update --init` to get the contents of the submodule if you missed using the `--recursive` option while cloning the repository or if you have already done so.
5. Open `CircuitVerse` directory
6. Open `Terminal` in the VS code
7. Run `./bin/docker_run`
8. Wait for the docker container to be prepared
9. Navigate to `http://localhost:3000` in your browser

If you required to restart the server
- Type `Ctrl+C` in terminal to stop the server
- Run `./bin/dev` to start the server again

### Windows Using Docker (Without WSL)
**Prerequisites**
|  Name | Version | Installation |
| --- | --- | --- |
| Git | Latest | [Download & Install](https://git-scm.com/downloads) |
| Docker | Latest | [Follow this guide to install](https://docs.docker.com/desktop/install/windows-install/) |

> **Note:** Supports both WSL-2 and Hyper-V based docker installation

**Steps to setup**
1. Fork current repository
2. Clone the forked repository
    ```bash
    git clone git@github.com:<username></username>/CircuitVerse.git --recursive
    ```
    - Use `git submodule update --init` to get the contents of the submodule if you missed using the `--recursive` option while cloning the repository or if you have already done so.
3. Open `CircuitVerse` directory
4. Open `PowerShell` in the current directory
5. Run `./bin/docker_run.ps1`
6. Wait for the docker container to be prepared
7. Navigate to `http://localhost:3000` in your browser

If you required to restart the server
- Type `Ctrl+C` in terminal to stop the server
- Run `./bin/dev` to start the server again

🔴 Windows can prevent the execution of Powershell Script, To resolve this issue,
- run the following command in Powershell as Administrator
```powershell
Set-ExecutionPolicy RemoteSigned
```
- Select `A` to allow all scripts to run
- That's all
- Now you can run `./bin/docker_run.ps1` without any issue

---

### Linux
**Prerequisites**
|  Name | Version | Installation |
| --- | --- | --- |
| Git | Latest | [Download & Install](https://git-scm.com/downloads) |
| Docker Engine | Latest | [Follow this guide to install](https://docs.docker.com/engine/install/)  ⚠️ Don't go for `Docker Desktop`. Check the `Supported Platforms` table to install docker engine CLI for your operating system |

**Note**

Before installing Docker Engine, ensure that Docker Desktop is not already installed on your local machine. If Docker Desktop is installed, you can follow this [guide](https://docs.docker.com/desktop/uninstall/) to completely remove it from your Linux machine.

After removing Docker Desktop, proceed with the installation of Docker Engine as specified in the docs.

**Steps to setup**
1. Fork current repository
2. Clone the forked repository
    ```bash
    git clone git@github.com:<username></username>/CircuitVerse.git --recursive
    ```
    - Use `git submodule update --init` to get the contents of the submodule if you missed using the `--recursive` option while cloning the repository or if you have already done so.
3. Open `CircuitVerse` directory
4. Open `Terminal` in the current directory
5. Run `./bin/docker_run`

If you required to restart the server
- Type `Ctrl+C` in terminal to stop the server
- Run `./bin/dev` to start the server again

---

### macOS
**Prerequisites**
|  Name | Version | Installation |
| --- | --- | --- |
| Git | Latest | [Download & Install](https://git-scm.com/downloads) |
| Docker | Latest | [Follow this guide to install](https://docs.docker.com/desktop/mac/install/) |

**Steps to setup**
1. Fork current repository
2. Clone the forked repository
    ```bash
    git clone git@github.com:<username></username>/CircuitVerse.git --recursive
    ```
    - Use `git submodule update --init` to get the contents of the submodule if you missed using the `--recursive` option while cloning the repository or if you have already done so.
3. Open `CircuitVerse` directory
4. Open `Terminal` in the current directory
5. Run `./bin/docker_run`

If you required to restart the server
- Type `Ctrl+C` in terminal to stop the server
- Run `./bin/dev` to start the server again

---

## Docker Development Environment

---

### Windows
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
    git clone git@github.com:<username></username>/CircuitVerse.git
    ```
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
| Docker | Latest | [Follow this guide to install](https://docs.docker.com/desktop/install/linux-install/) |

**Steps to setup**
1. Fork current repository
2. Clone the forked repository
    ```bash
    git clone git@github.com:<username></username>/CircuitVerse.git
    ```
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
    git clone git@github.com:<username></username>/CircuitVerse.git
    ```
3. Open `CircuitVerse` directory
4. Open `Terminal` in the current directory
5. Run `./bin/docker_run`

If you required to restart the server
- Type `Ctrl+C` in terminal to stop the server
- Run `./bin/dev` to start the server again

---

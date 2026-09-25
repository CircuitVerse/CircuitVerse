## Docker Development Environment

---

> **Note: Upgrading from PostgreSQL 14 to 17**
>
> PostgreSQL major-version data directories are **not directly interchangeable**. If you have an
> existing `postgres_data` Docker volume created with PostgreSQL 14, you must migrate your data
> before switching to the `postgres:17` image in `docker-compose.yml`.
>
> Two supported approaches:
>
> **Option 1 — `pg_dump` / `pg_restore`** (recommended for most users)
> 1. With the PostgreSQL 14 container still running, dump your database:
>    ```bash
>    docker compose exec db pg_dump -U postgres circuitverse_development > cv_backup.sql
>    ```
> 2. Stop the stack, confirm the volume name, then remove the old volume:
>    ```bash
>    docker compose down
>    docker volume ls | grep postgres_data   # confirm the exact volume name (typically circuitverse_postgres_data)
>    docker volume rm circuitverse_postgres_data
>    ```
> 3. Start the stack with the new PostgreSQL 17 image (creates a fresh volume):
>    ```bash
>    docker compose up -d db
>    ```
> 4. Restore your data:
>    ```bash
>    docker compose exec -T db psql -U postgres circuitverse_development < cv_backup.sql
>    ```
>
> **Option 2 — `pg_upgrade`**
> Use the [tianon/docker-postgres-upgrade](https://github.com/tianon/docker-postgres-upgrade)
> image to perform an in-place major-version upgrade without losing your existing volume.
>
> Do **not** simply point the new `postgres:17` image at an existing PostgreSQL 14 data directory —
> the server will refuse to start.

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

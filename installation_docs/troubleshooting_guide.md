## Troubleshoot Guide

---

### 1. Sprockets::Rails::Helper::AssetNotFound in CircuitVerse#index

![image](https://github.com/CircuitVerse/CircuitVerse/assets/57363826/5e707303-5147-4645-89e4-715c7b70a3f5)

**What's happening?**

This error occurs when Rails cannot find the `application.js` file in the asset pipeline. The file is compiled by esbuild from `app/javascript/` to `app/assets/builds/`. In Docker, if Rails starts before the asset compilation finishes (or if dependencies weren't installed properly), you'll see this error.

---

#### Solution A: Wait and Refresh (Recommended First)

Simply wait for 30-60 seconds and refresh the page. The `asset_build` Docker service compiles assets in the background, and it may take a moment to complete.

---

#### Solution B: Manual Asset Precompilation (If Solution A Doesn't Work)

If waiting doesn't resolve the issue, the Ruby dependencies may not have been installed properly. Follow these steps to manually install dependencies and precompile assets:

**Step 1:** Start the Docker containers in detached mode (runs in background)
```bash
docker compose up -d
```
> This starts all services defined in `docker-compose.yml` without blocking your terminal.

**Step 2:** Open a bash shell inside the `web` container
```bash
docker compose exec web bash
```
> You should now see a prompt like `root@a1b2c3d4:/circuitverse#` indicating you're inside the container.

**Step 3:** Install Ruby gem dependencies
```bash
bundle install
```
> This installs all gems listed in `Gemfile`. Rails needs these dependencies to compile assets.

**Step 4:** Precompile the assets manually
```bash
bundle exec rake assets:precompile
```
> This runs the Rails asset pipeline to compile `application.js` and other assets into the `public/assets/` folder.

**Step 5:** Exit the container shell
```bash
exit
```

**Step 6:** Restart the Docker containers
```bash
docker compose down
docker compose up
```
> This cleanly restarts all services with the newly compiled assets.

Now refresh your browser - the error should be resolved!

---

### 2. `$'\r': command not found` Errors When Running `build.sh`

**What's happening?**

This error occurs because the `build.sh` script has Windows-style line endings (CRLF) instead of Unix-style line endings (LF). Docker containers run Linux, which doesn't recognize CRLF line endings.

---

#### Solution: Convert CRLF to LF in VS Code

**Step 1:** Open `cv-frontend-vue/build.sh` in VS Code

**Step 2:** Look at the bottom-right corner of VS Code - you'll see either `CRLF` or `LF`

**Step 3:** Click on `CRLF` to open the line ending selector

**Step 4:** Select `LF` from the dropdown menu

**Step 5:** Save the file (`Ctrl+S` or `Cmd+S`)

The script should now run without the `$'\r'` errors.

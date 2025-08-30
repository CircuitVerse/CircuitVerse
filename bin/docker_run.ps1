# Set environment variables
$env:NON_ROOT_USERNAME = "root";
$env:NON_ROOT_GROUPNAME = "root";
$env:OPERATING_SYSTEM = "windows";
$env:PWD = (Get-Location).Path;
$env:CURRENT_UID = "0";
$env:CURRENT_GID = "0";

# Check if docker is available
if (Get-Command -Name "docker" -ErrorAction SilentlyContinue) {
    # Run docker-compose up
    docker compose up -d --build
    # Run docker-compose exec to boot the image
    docker compose exec web bin/docker/boot
    # Run docker-compose down
    docker compose down
}
else {
    Write-Output "Docker is not available. Follow this documentation to install docker: https://docs.docker.com/desktop/install/windows-install/"
}
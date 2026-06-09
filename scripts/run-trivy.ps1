<#
Run Trivy scans for the project.

<#
Run Trivy scans for the project.

Usage:
  Open PowerShell in repo root and run:
    ./scripts/run-trivy.ps1

Requirements:
  - Docker installed (required to build the image)
  - Trivy installed (optional). If not installed, the script will use the official Trivy Docker image.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Run-TrivyImage {
    param(
        [Parameter(Mandatory = $true)][string]$ImageName,
        [Parameter(Mandatory = $true)][string]$OutJson,
        [Parameter(Mandatory = $true)][string]$OutSarif
    )

    $cwd = (Get-Location).Path
    $cacheDir = Join-Path $cwd '.trivy-cache'
    if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir | Out-Null }

    # prefer local trivy if available
    if (Get-Command trivy -ErrorAction SilentlyContinue) {
        Write-Host "Attempting local trivy image scan -> $OutJson"
        try {
            trivy image --scanners vuln --timeout 15m --format json -o $OutJson $ImageName
            trivy image --scanners vuln --timeout 15m --format sarif -o $OutSarif $ImageName
            return
        } catch {
            Write-Warning "Local trivy invocation failed: $_. Falling back to container-based scan."
        }
    } else {
        Write-Host "Trivy CLI not found locally. Will use container-based scan (using saved image tar)."
    }

    # When running Trivy in a container, scanning the host's docker daemon is fragile on Windows.
    # Instead, export the image to a tar and scan the tar with --input. This avoids requiring the docker socket.
    $tarPath = Join-Path $cwd 'circuitverse.tar'
    Write-Host "Saving image '$ImageName' to tar: $tarPath"
    & docker save $ImageName -o $tarPath
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $tarPath)) {
        Write-Warning "docker save failed for $ImageName (exit $LASTEXITCODE). Skipping image scan."
        return
    }

    $trivyImageCandidates = @('ghcr.io/aquasecurity/trivy:latest', 'aquasecurity/trivy:latest', 'aquasec/trivy:latest')
    $pulled = $false
    foreach ($candidate in $trivyImageCandidates) {
        Write-Host "Trying Trivy image candidate: $candidate (scanning tar input)"
        & docker run --rm -v "${cwd}:/workspace" -v "${cwd}/.trivy-cache:/root/.cache/trivy" -w /workspace $candidate image --scanners vuln --timeout 15m --input /workspace/$(Split-Path $tarPath -Leaf) --format json -o /workspace/$OutJson
        if ($LASTEXITCODE -eq 0) { $pulled = $true; break }
        Write-Warning "docker run (trivy image json) with $candidate failed (exit $LASTEXITCODE)."
    }
    if (-not $pulled) { Write-Warning "All Trivy image candidates failed for image scan." }

    if ($pulled) {
        & docker run --rm -v "${cwd}:/workspace" -v "${cwd}/.trivy-cache:/root/.cache/trivy" -w /workspace $candidate image --scanners vuln --timeout 15m --input /workspace/$(Split-Path $tarPath -Leaf) --format sarif -o /workspace/$OutSarif
        if ($LASTEXITCODE -ne 0) { Write-Warning "docker run (trivy image sarif) with $candidate failed (exit $LASTEXITCODE)." }
    }

    # cleanup local tar to save disk space
    try { Remove-Item -Path $tarPath -Force -ErrorAction SilentlyContinue } catch {}
}

function Run-TrivyFs {
    param(
        [Parameter(Mandatory = $true)][string]$OutJson,
        [Parameter(Mandatory = $true)][string]$OutSarif
    )

    $cwd = (Get-Location).Path
    $trivyImageCandidates = @('ghcr.io/aquasecurity/trivy:latest', 'aquasecurity/trivy:latest', 'aquasec/trivy:latest')
    $cacheDir = Join-Path $cwd '.trivy-cache'
    if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir | Out-Null }

    if (Get-Command trivy -ErrorAction SilentlyContinue) {
        Write-Host "Attempting local trivy filesystem scan -> $OutJson"
        try {
            trivy fs --scanners vuln --timeout 15m --format json -o $OutJson $cwd
            trivy fs --scanners vuln --timeout 15m --format sarif -o $OutSarif $cwd
            return
        } catch {
            Write-Warning "Local trivy fs invocation failed: $_. Falling back to Docker image."
        }
    } else {
        Write-Host "Trivy CLI not found locally. Will try Docker image candidates: $($trivyImageCandidates -join ', ')"
    }
    $pulled = $false
    foreach ($candidate in $trivyImageCandidates) {
        Write-Host "Trying Trivy FS candidate: $candidate"
        & docker run --rm -v "${cwd}:/workspace" -v "${cwd}/.trivy-cache:/root/.cache/trivy" -w /workspace $candidate fs --scanners vuln --timeout 15m --format json -o /workspace/$OutJson /workspace
        if ($LASTEXITCODE -eq 0) { $pulled = $true; break }
        Write-Warning "docker run (trivy fs json) with $candidate failed (exit $LASTEXITCODE)."
    }
    if (-not $pulled) { Write-Warning "All Trivy image candidates failed for filesystem scan." }

    if ($pulled) {
        & docker run --rm -v "${cwd}:/workspace" -v "${cwd}/.trivy-cache:/root/.cache/trivy" -w /workspace $candidate fs --scanners vuln --timeout 15m --format sarif -o /workspace/$OutSarif /workspace
        if ($LASTEXITCODE -ne 0) { Write-Warning "docker run (trivy fs sarif) with $candidate failed (exit $LASTEXITCODE)." }
    }
}

function Summarize-Results {
    param(
        [Parameter(Mandatory = $true)][string]$JsonFile
    )

    if (-not (Test-Path $JsonFile)) { Write-Host "No results file: $JsonFile"; return }
    try {
        $raw = Get-Content $JsonFile -Raw
        if ([string]::IsNullOrWhiteSpace($raw)) { Write-Host "Empty results: $JsonFile"; return }
        $data = $raw | ConvertFrom-Json -ErrorAction Stop
        # Trivy may emit either an object with .Results or an array of objects
        $allResults = @()
        if ($data -is [System.Array]) {
            foreach ($item in $data) {
                if ($null -ne $item.Results) { $allResults += $item.Results }
            }
        } elseif ($null -ne $data.Results) {
            $allResults += $data.Results
        }
        if ($allResults.Count -eq 0) { Write-Host "No Results object in $JsonFile"; return }
        $vuls = @()
        foreach ($r in $allResults) { if ($null -ne $r.Vulnerabilities) { $vuls += $r.Vulnerabilities } }
        if ($vuls.Count -eq 0) { Write-Host "No vulnerabilities found in $JsonFile"; return }
        $groups = $vuls | Group-Object -Property Severity | Sort-Object Count -Descending
        Write-Host "Summary for $JsonFile"
        foreach ($g in $groups) { Write-Host ("  {0}: {1}" -f $g.Name, $g.Count) }
    } catch {
        Write-Warning ("Failed to summarize {0}: {1}" -f $JsonFile, $_.ToString())
    }
}

# Main
try {
    Write-Host "Building Docker image: circuitverse:local"
    # sensible defaults for build args required by the project's Dockerfile
    $nonRootUserId = if ($env:NON_ROOT_USER_ID) { $env:NON_ROOT_USER_ID } else { '1000' }
    $nonRootGroupId = if ($env:NON_ROOT_GROUP_ID) { $env:NON_ROOT_GROUP_ID } else { '1000' }
    $operatingSystem = if ($env:OPERATING_SYSTEM) { $env:OPERATING_SYSTEM } else { 'linux' }
    $nonRootUserName = if ($env:NON_ROOT_USERNAME) { $env:NON_ROOT_USERNAME } else { 'cvuser' }
    $nonRootGroupName = if ($env:NON_ROOT_GROUPNAME) { $env:NON_ROOT_GROUPNAME } else { 'cvgroup' }

    $buildCmdArgs = @(
        'build',
        '--build-arg', "NON_ROOT_USER_ID=$nonRootUserId",
        '--build-arg', "NON_ROOT_GROUP_ID=$nonRootGroupId",
        '--build-arg', "OPERATING_SYSTEM=$operatingSystem",
        '--build-arg', "NON_ROOT_USERNAME=$nonRootUserName",
        '--build-arg', "NON_ROOT_GROUPNAME=$nonRootGroupName",
        '-t', 'circuitverse:local',
        '.'
    )

    Write-Host "Running: docker $($buildCmdArgs -join ' ')"
    & docker @buildCmdArgs
    if ($LASTEXITCODE -ne 0) { Write-Error "Docker build failed (exit code $LASTEXITCODE). Aborting."; exit 2 }

    $imgJson = "trivy-image.json"
    $imgSarif = "trivy-image.sarif"
    $fsJson = "trivy-fs.json"
    $fsSarif = "trivy-fs.sarif"

    Run-TrivyImage -ImageName 'circuitverse:local' -OutJson $imgJson -OutSarif $imgSarif
    Run-TrivyFs -OutJson $fsJson -OutSarif $fsSarif

    Summarize-Results -JsonFile $imgJson
    Summarize-Results -JsonFile $fsJson

    Write-Host "Artifacts: $imgJson, $imgSarif, $fsJson, $fsSarif"
    Write-Host "Done. If you want to upload SARIF files to GitHub Code Scanning, use the upload-sarif action in a workflow or the GitHub UI."
    exit 0
} catch {
    Write-Error "Unexpected error: $_"
    exit 3
}

$downloadBetaLink = "https://go.microsoft.com/fwlink/?linkid=2069324&Channel=Dev&language=en-us&Consent=0&IID=85213fc4-6a13-57ae-9082-72910982ede8"
$betaSetup = "C:\MicrosoftEdgeSetupBeta.exe"

#  Note: We're purposely skipping the -Wait flag in Start-Process.
#  This is because Edge auto-launches after the setup is done and
#  Start-Process continues to indefinitely wait on that process.
Write-Host "Downloading Microsoft Edge (Beta)..." -ForegroundColor cyan
Invoke-WebRequest $downloadBetaLink -OutFile $betaSetup
Write-Host "Installing..." -ForegroundColor cyan
Start-Process $betaSetup
Write-Host "Microsoft Edge (Beta) installed.`n" -ForegroundColor green
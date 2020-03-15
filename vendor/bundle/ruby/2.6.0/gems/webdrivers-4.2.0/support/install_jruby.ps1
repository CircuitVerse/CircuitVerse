$downloadLink = "https://repo1.maven.org/maven2/org/jruby/jruby-dist/9.2.9.0/jruby-dist-9.2.9.0-bin.zip"
$zipPath = "c:\jruby-dist-9.2.9.0-bin.zip"

Write-Host "Installing $($env:RUBY_VERSION)" -ForegroundColor cyan
appveyor DownloadFile "$($downloadLink)" -FileName "$($zipPath)"
7z x "$($zipPath)" -oc:\ -y # Unzip to c:\
Write-Host "JRuby installed.`n" -ForegroundColor green

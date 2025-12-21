# PowerShell script to sync GLADIS project to Raspberry Pi
# Usage: .\sync-to-pi.ps1

$PI_IP = "192.168.1.87"
$PI_USER = "erhan"  # Change this if your username is different
$PI_DEST = "~/gladis"

Write-Host "Syncing GLADIS project to Raspberry Pi at $PI_IP..." -ForegroundColor Cyan

# Get the current directory
$PROJECT_DIR = $PSScriptRoot

# Use rsync if available (via WSL or Git Bash), otherwise use scp
if (Get-Command rsync -ErrorAction SilentlyContinue) {
    Write-Host "Using rsync for sync..." -ForegroundColor Green

    # Rsync with exclusions based on .gitignore
    rsync -avz --progress `
        --exclude 'build/' `
        --exclude 'build-*/' `
        --exclude 'cmake-build-*/' `
        --exclude 'deploy/' `
        --exclude '*-bundle/' `
        --exclude '*.AppImage' `
        --exclude '*.tar.gz' `
        --exclude '*.tar.xz' `
        --exclude '*.zip' `
        --exclude '.git/' `
        --exclude '.vscode/' `
        --exclude '.idea/' `
        --exclude '*.o' `
        --exclude '*.so' `
        --exclude '*.a' `
        --exclude '*.log' `
        "$PROJECT_DIR/" "${PI_USER}@${PI_IP}:${PI_DEST}/"
} else {
    Write-Host "rsync not found, using scp (this will copy all files)..." -ForegroundColor Yellow
    Write-Host "For better performance, consider installing rsync via WSL or Git Bash" -ForegroundColor Yellow

    # Create directory on Pi first
    ssh "${PI_USER}@${PI_IP}" "mkdir -p ${PI_DEST}"

    # Use scp to copy everything
    scp -r "$PROJECT_DIR/*" "${PI_USER}@${PI_IP}:${PI_DEST}/"
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSync completed successfully!" -ForegroundColor Green
    Write-Host "Project copied to: ${PI_USER}@${PI_IP}:${PI_DEST}" -ForegroundColor Green
} else {
    Write-Host "`nSync failed!" -ForegroundColor Red
    exit 1
}

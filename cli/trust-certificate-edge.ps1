# Script to trust the localhost certificate for Chrome AND Edge
# Run this as Administrator for best results (works for CurrentUser without admin)

$cerPath = "$PSScriptRoot\..\certs\localhost.cer"

if (-not (Test-Path $cerPath)) {
    Write-Host "ERROR: CER file not found at: $cerPath" -ForegroundColor Red
    Write-Host "Please generate a certificate first." -ForegroundColor Yellow
    exit 1
}

Write-Host "🔒 Trusting certificate for Chrome and Edge browsers..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Found CER file: $cerPath" -ForegroundColor Gray
Write-Host ""

$success = $false

# Try CurrentUser Root first (no admin needed, works for Chrome and Edge)
Write-Host "Attempting to add certificate to CurrentUser Trusted Root..." -ForegroundColor Yellow
try {
    Import-Certificate -FilePath $cerPath -CertStoreLocation Cert:\CurrentUser\Root -ErrorAction Stop | Out-Null
    Write-Host "✅ SUCCESS: Certificate added to CurrentUser Trusted Root!" -ForegroundColor Green
    Write-Host "   This works for both Chrome and Edge browsers." -ForegroundColor Gray
    $success = $true
} catch {
    Write-Host "⚠️  Could not add to CurrentUser Root: $_" -ForegroundColor Yellow
    Write-Host ""
}

# Try LocalMachine Root (requires admin, works system-wide)
if (-not $success) {
    Write-Host "Attempting to add certificate to LocalMachine Trusted Root (requires admin)..." -ForegroundColor Yellow
    try {
        Import-Certificate -FilePath $cerPath -CertStoreLocation Cert:\LocalMachine\Root -ErrorAction Stop | Out-Null
        Write-Host "✅ SUCCESS: Certificate added to LocalMachine Trusted Root!" -ForegroundColor Green
        Write-Host "   This works for all browsers system-wide." -ForegroundColor Gray
        $success = $true
    } catch {
        Write-Host "❌ ERROR: Could not add to LocalMachine Root: $_" -ForegroundColor Red
        Write-Host ""
    }
}

if ($success) {
    Write-Host ""
    Write-Host "✅ Certificate trusted successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next steps for Edge:" -ForegroundColor Cyan
    Write-Host "   1. Close ALL Edge windows completely" -ForegroundColor White
    Write-Host "   2. Restart your server (if not already running)" -ForegroundColor White
    Write-Host "   3. Open Edge and visit: https://localhost:3000" -ForegroundColor White
    Write-Host "   4. You should see 'Secure' (padlock icon) ✅" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Note: Edge uses Windows certificate store, so the certificate" -ForegroundColor Gray
    Write-Host "   should work automatically after browser restart." -ForegroundColor Gray
    Write-Host ""
    exit 0
} else {
    Write-Host ""
    Write-Host "❌ Could not automatically trust certificate." -ForegroundColor Red
    Write-Host ""
    Write-Host "To manually trust the certificate for Edge:" -ForegroundColor Yellow
    Write-Host "   1. Double-click: $cerPath" -ForegroundColor White
    Write-Host "   2. Click 'Install Certificate...'" -ForegroundColor White
    Write-Host "   3. Choose 'Current User' (recommended) or 'Local Machine'" -ForegroundColor White
    Write-Host "   4. Select 'Place all certificates in the following store'" -ForegroundColor White
    Write-Host "   5. Click 'Browse' and select 'Trusted Root Certification Authorities'" -ForegroundColor White
    Write-Host "   6. Click 'OK', 'Next', 'Finish', then 'Yes'" -ForegroundColor White
    Write-Host "   7. Close ALL Edge windows and reopen" -ForegroundColor White
    Write-Host "   8. Visit https://localhost:3000" -ForegroundColor White
    Write-Host ""
    exit 1
}


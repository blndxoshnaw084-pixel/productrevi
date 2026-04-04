flutter build web --base-href "/productrevi/"

if (Test-Path docs) { 
    Remove-Item -Recurse -Force docs 
}
mkdir docs
xcopy /E /I /Y build\web docs > $null

git add .
git commit -m "Auto update: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main --force

Write-Host "✅ Done!" -ForegroundColor Green
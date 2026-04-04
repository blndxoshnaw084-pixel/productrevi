# 1. Build the web project
flutter build web --base-href "/productrevi/"

# 2. Refresh the docs folder
if (Test-Path docs) { rd /s /q docs }
mkdir docs
xcopy /E /I /Y build\web docs

# 3. Push to GitHub
git add .
git commit -m "Auto update: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main

Write-Host "✅ هەمەوو شتێک بە سەرکەوتوویی نوێ بووەوە!" -ForegroundColor Green
param(
    [switch]$AutoConfirm = $false,
    [switch]$SkipRecycleBin = $false
)

# Запрос прав администратора
$isAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $isAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Требуются права администратора" -ForegroundColor Yellow
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -AutoConfirm:$($AutoConfirm.IsPresent) -SkipRecycleBin:$($SkipRecycleBin.IsPresent)" -Verb RunAs
    exit
}

# Подтверждение
if (-not $AutoConfirm) {
    $message = @"
Будет выполнено:
1. Очистка системной папки Temp
2. Очистка вашей папки %Temp%
3. Очистка DNS-кэша
4. Очистка корзины (если не отключено)

Продолжить? (y/n)
"@
    $confirmation = Read-Host $message
    if ($confirmation -ne 'y') { exit }
}

# 1. Очистка системного Temp (только старые файлы)
$systemTemp = "$env:SystemRoot\Temp"
if (Test-Path $systemTemp) {
    Get-ChildItem $systemTemp -Recurse -Force | Where-Object {
        $_.LastWriteTime -lt (Get-Date).AddDays(-1) -and
        $_.FullName -notmatch "\\Windows\\Temp\\[A-Za-z0-9]{8}-([A-Za-z0-9]{4}-){3}[A-Za-z0-9]{12}"  # Исключаем папки установщика Windows
    } | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "[✓] Системный Temp очищен" -ForegroundColor Green
}

# 2. Очистка пользовательского Temp (для текущего пользователя)
$userTemp = [System.IO.Path]::GetTempPath()
if (Test-Path $userTemp) {
    Get-ChildItem $userTemp -Recurse -Force | Where-Object {
        $_.LastWriteTime -lt (Get-Date).AddDays(-7)  # Более агрессивная очистка
    } | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "[✓] Папка %Temp% очищена" -ForegroundColor Green
}

# 3. Очистка DNS-кэша
try {
    ipconfig /flushdns 2>&1 | Out-Null
    Write-Host "[✓] DNS-кэш очищен" -ForegroundColor Green
} catch {
    Write-Host "[!] Ошибка очистки DNS" -ForegroundColor Red
}

# 4. Очистка корзины (только для текущего пользователя)
if (-not $SkipRecycleBin) {
    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Host "[✓] Корзина очищена" -ForegroundColor Green
    } catch {
        Write-Host "[!] Ошибка очистки корзины: $_" -ForegroundColor Red
    }
}

# Итог
Write-Host "`nГотово! Все операции выполнены." -ForegroundColor Cyan
if (-not $AutoConfirm) {
    Read-Host "Нажмите Enter для выхода"
}
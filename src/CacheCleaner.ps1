param(
    [switch]$AutoConfirm = $false,
    [switch]$SkipRecycleBin = $false
)

$isAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $isAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "powershell.exe"
    $processInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -AutoConfirm:$($AutoConfirm.IsPresent) -SkipRecycleBin:$($SkipRecycleBin.IsPresent)"
    $processInfo.Verb = "runas"
    $processInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    try {
        [System.Diagnostics.Process]::Start($processInfo) | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Ошибка при запросе прав администратора: $_", 
            "Ошибка", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
    exit
}

if ($AutoConfirm) {
    exit
}

Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0) | Out-Null

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Очистка системы"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

$iconPath = "D:\Project\CacheCleaner\build\icon.ico"
if (Test-Path $iconPath) {
    try {
        $form.Icon = [System.Drawing.Icon]::new($iconPath)
    } catch {
        $fallbackIcon = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('System'), 'shell32.dll')
        $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fallbackIcon)
    }
} else {
    $fallbackIcon = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('System'), 'shell32.dll')
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fallbackIcon)
}

$header = New-Object System.Windows.Forms.Label
$header.Text = "Очистка системы"
$header.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$header.ForeColor = [System.Drawing.Color]::DarkSlateBlue
$header.Size = New-Object System.Drawing.Size(400, 30)
$header.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($header)

$actionsPanel = New-Object System.Windows.Forms.GroupBox
$actionsPanel.Text = "Выберите действия:"
$actionsPanel.Location = New-Object System.Drawing.Point(20, 70)
$actionsPanel.Size = New-Object System.Drawing.Size(540, 150)
$actionsPanel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

$chkSystemTemp = New-Object System.Windows.Forms.CheckBox
$chkSystemTemp.Text = "Очистить системную папку Temp"
$chkSystemTemp.Location = New-Object System.Drawing.Point(20, 30)
$chkSystemTemp.Size = New-Object System.Drawing.Size(250, 20)
$chkSystemTemp.Checked = $true
$actionsPanel.Controls.Add($chkSystemTemp)

$chkUserTemp = New-Object System.Windows.Forms.CheckBox
$chkUserTemp.Text = "Очистить папку %Temp% текущего пользователя"
$chkUserTemp.Location = New-Object System.Drawing.Point(20, 60)
$chkUserTemp.Size = New-Object System.Drawing.Size(300, 20)
$chkUserTemp.Checked = $true
$actionsPanel.Controls.Add($chkUserTemp)

$chkDns = New-Object System.Windows.Forms.CheckBox
$chkDns.Text = "Очистить DNS-кэш"
$chkDns.Location = New-Object System.Drawing.Point(20, 90)
$chkDns.Size = New-Object System.Drawing.Size(200, 20)
$chkDns.Checked = $true
$actionsPanel.Controls.Add($chkDns)

$chkRecycleBin = New-Object System.Windows.Forms.CheckBox
$chkRecycleBin.Text = "Очистить корзину"
$chkRecycleBin.Location = New-Object System.Drawing.Point(280, 30)
$chkRecycleBin.Size = New-Object System.Drawing.Size(200, 20)
$chkRecycleBin.Checked = -not $SkipRecycleBin
$actionsPanel.Controls.Add($chkRecycleBin)

$form.Controls.Add($actionsPanel)

$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Location = New-Object System.Drawing.Point(20, 240)
$logBox.Size = New-Object System.Drawing.Size(540, 160)
$logBox.ReadOnly = $true
$logBox.BackColor = [System.Drawing.Color]::White
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($logBox)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 410)
$progressBar.Size = New-Object System.Drawing.Size(540, 20)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

$btnClean = New-Object System.Windows.Forms.Button
$btnClean.Text = "Выполнить очистку"
$btnClean.Location = New-Object System.Drawing.Point(20, 440)
$btnClean.Size = New-Object System.Drawing.Size(180, 30)
$btnClean.BackColor = [System.Drawing.Color]::RoyalBlue
$btnClean.ForeColor = [System.Drawing.Color]::White
$btnClean.FlatStyle = "Flat"
$btnClean.FlatAppearance.BorderSize = 0
$btnClean.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Выход"
$btnExit.Location = New-Object System.Drawing.Point(220, 440)
$btnExit.Size = New-Object System.Drawing.Size(120, 30)
$btnExit.BackColor = [System.Drawing.Color]::LightGray
$btnExit.FlatStyle = "Flat"
$btnExit.FlatAppearance.BorderSize = 0

$form.Controls.Add($btnClean)
$form.Controls.Add($btnExit)

function Add-Log {
    param(
        [string]$Message,
        [string]$Color = "Black"
    )
    
    $colorMap = @{
        "Green" = [System.Drawing.Color]::ForestGreen
        "Red" = [System.Drawing.Color]::Firebrick
        "Blue" = [System.Drawing.Color]::RoyalBlue
        "Orange" = [System.Drawing.Color]::DarkOrange
        "Black" = [System.Drawing.Color]::Black
    }
    
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.SelectionLength = 0
    $logBox.SelectionColor = $colorMap[$Color]
    $logBox.AppendText("$(Get-Date -Format 'HH:mm:ss') $Message`n")
    $logBox.SelectionColor = $logBox.ForeColor
    $logBox.ScrollToCaret()
}

$btnClean.Add_Click({
    $btnClean.Enabled = $false
    $btnExit.Enabled = $false
    $progressBar.Value = 0
    Add-Log "Запуск процесса очистки..." -Color Blue
    
    $actions = @()
    if ($chkSystemTemp.Checked) { $actions += "Системный Temp" }
    if ($chkUserTemp.Checked) { $actions += "Пользовательский Temp" }
    if ($chkDns.Checked) { $actions += "DNS-кэш" }
    if ($chkRecycleBin.Checked) { $actions += "Корзина" }
    
    $totalSteps = $actions.Count
    $currentStep = 0

    foreach ($action in $actions) {
        $currentStep++
        $progressBar.Value = ($currentStep / $totalSteps) * 100
        
        switch ($action) {
            "Системный Temp" {
                Add-Log "Очистка системной папки Temp..."
                $systemTemp = "$env:SystemRoot\Temp"
                if (Test-Path $systemTemp) {
                    $files = Get-ChildItem $systemTemp -Recurse -Force -ErrorAction SilentlyContinue | 
                             Where-Object { 
                                 $_.LastWriteTime -lt (Get-Date).AddDays(-1) -and
                                 $_.FullName -notmatch "\\Windows\\Temp\\[A-Za-z0-9]{8}-([A-Za-z0-9]{4}-){3}[A-Za-z0-9]{12}"
                             }
                    if ($files) {
                        $files | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                        Add-Log "Удалено $($files.Count) объектов" -Color Green
                    } else {
                        Add-Log "Нет файлов для удаления" -Color Orange
                    }
                }
            }
            
            "Пользовательский Temp" {
                Add-Log "Очистка папки %Temp%..."
                $userTemp = [System.IO.Path]::GetTempPath()
                if (Test-Path $userTemp) {
                    $files = Get-ChildItem $userTemp -Recurse -Force -ErrorAction SilentlyContinue | 
                             Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
                    if ($files) {
                        $files | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                        Add-Log "Удалено $($files.Count) объектов" -Color Green
                    } else {
                        Add-Log "Нет файлов для удаления" -Color Orange
                    }
                }
            }
            
            "DNS-кэш" {
                Add-Log "Очистка DNS-кэша..."
                try {
                    ipconfig /flushdns 2>&1 | Out-Null
                    Add-Log "DNS-кэш успешно очищен" -Color Green
                } catch {
                    Add-Log "Ошибка очистки DNS: $_" -Color Red
                }
            }
            
            "Корзина" {
                Add-Log "Очистка корзины..."
                try {
                    Clear-RecycleBin -Force -ErrorAction Stop
                    Add-Log "Корзина успешно очищена" -Color Green
                } catch {
                    Add-Log "Ошибка очистки корзины: $_" -Color Red
                }
            }
        }
        [System.Windows.Forms.Application]::DoEvents()
    }
    
    $progressBar.Value = 100
    Add-Log "`nОчистка завершена успешно!" -Color Blue
    $btnClean.Enabled = $true
    $btnExit.Enabled = $true
})

$btnExit.Add_Click({ $form.Close() })

[void]$form.ShowDialog()

exit
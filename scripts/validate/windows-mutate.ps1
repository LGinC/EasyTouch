param(
    [string]$EasyTouchPath = "zig-out/bin/et.exe",
    [string]$ArtifactDir = "zig-out/validation",
    [int]$TimeoutMs = 2000
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class EasyTouchValidationNative {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool BringWindowToTop(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
'@

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptRoot "../.."))
$easyTouchExe = if ([System.IO.Path]::IsPathRooted($EasyTouchPath)) {
    $EasyTouchPath
} else {
    [System.IO.Path]::GetFullPath((Join-Path $repoRoot $EasyTouchPath))
}
$artifactPath = if ([System.IO.Path]::IsPathRooted($ArtifactDir)) {
    $ArtifactDir
} else {
    [System.IO.Path]::GetFullPath((Join-Path $repoRoot $ArtifactDir))
}
$wshShell = New-Object -ComObject WScript.Shell

if (-not (Test-Path -LiteralPath $easyTouchExe)) {
    throw "EasyTouch executable not found: $easyTouchExe"
}

New-Item -ItemType Directory -Force -Path $artifactPath | Out-Null

function Invoke-EasyTouchJson {
    param(
        [string[]]$Arguments
    )

    $rawOutput = & $script:easyTouchExe @Arguments 2>&1
    $rawText = ($rawOutput | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
    if ([string]::IsNullOrWhiteSpace($rawText)) {
        throw "EasyTouch returned empty output for arguments: $($Arguments -join ' ')"
    }

    try {
        $parsed = $rawText | ConvertFrom-Json
    } catch {
        throw "Failed to parse EasyTouch JSON for arguments '$($Arguments -join ' ')':`n$rawText"
    }

    return [PSCustomObject]@{
        Arguments = $Arguments
        Raw = $rawText
        Json = $parsed
    }
}

function New-ValidationResult {
    param(
        [bool]$Ok,
        [string]$Status,
        [string]$Message,
        [hashtable]$Extra
    )

    $result = [ordered]@{
        ok = $Ok
        status = $Status
        message = $Message
        timestamp = (Get-Date).ToString('o')
        easytouch_path = $easyTouchExe
    }

    foreach ($entry in $Extra.GetEnumerator()) {
        $result[$entry.Key] = $entry.Value
    }

    return $result
}

function Focus-FixtureWindow {
    param(
        [System.Windows.Forms.Form]$Window,
        [System.Windows.Forms.Control]$FocusControl
    )

    $restoreWindow = 9
    [EasyTouchValidationNative]::ShowWindow($Window.Handle, $restoreWindow) | Out-Null
    [EasyTouchValidationNative]::BringWindowToTop($Window.Handle) | Out-Null
    [EasyTouchValidationNative]::SetForegroundWindow($Window.Handle) | Out-Null
    $script:wshShell.AppActivate($Window.Text) | Out-Null
    [void]$Window.Activate()
    if ($FocusControl) {
        [void]$FocusControl.Focus()
    }
    Start-Sleep -Milliseconds 250
}

function Wait-ForForegroundTitle {
    param(
        [string]$ExpectedTitle,
        [int]$Attempts = 8,
        [int]$DelayMs = 200
    )

    for ($attempt = 0; $attempt -lt $Attempts; $attempt += 1) {
        $foreground = Invoke-EasyTouchJson -Arguments @('window', 'foreground', '--output', 'json')
        if ($foreground.Json.ok -and $foreground.Json.data.found -and $foreground.Json.data.window.title -eq $ExpectedTitle) {
            return $foreground.Json
        }

        if ($attempt -lt ($Attempts - 1)) {
            Start-Sleep -Milliseconds $DelayMs
        }
    }

    throw "Foreground window never matched '$ExpectedTitle'."
}

function Ensure-FixtureWindowForeground {
    param(
        [System.Windows.Forms.Form]$Window,
        [System.Windows.Forms.Control]$FocusControl,
        [int]$Attempts = 6
    )

    for ($attempt = 0; $attempt -lt $Attempts; $attempt += 1) {
        Focus-FixtureWindow -Window $Window -FocusControl $FocusControl

        try {
            return Wait-ForForegroundTitle -ExpectedTitle $Window.Text -Attempts 1 -DelayMs 0
        } catch {
            if ($attempt -lt ($Attempts - 1)) {
                Start-Sleep -Milliseconds 200
            }
        }
    }

    throw "Fixture window did not become the exact foreground target."
}

$sentinel = "easytouch-validation-" + [Guid]::NewGuid().ToString('N')
$wrongGuard = "wrong-target-" + [Guid]::NewGuid().ToString('N')
$windowTitle = "EasyTouch Validation " + [Guid]::NewGuid().ToString('N')
$companionTitle = "EasyTouch Window Activation " + [Guid]::NewGuid().ToString('N')
$resultFile = Join-Path $artifactPath 'windows-mutate-result.json'

$clipboardMode = 'unknown'
$clipboardBackup = $null
$restoreClipboard = {}

try {
    try {
        $clipboardBackup = [System.Windows.Forms.Clipboard]::GetDataObject()
        if ($clipboardBackup -and $clipboardBackup.GetFormats().Count -gt 0) {
            $clipboardMode = 'data-object'
            $restoreClipboard = {
                [System.Windows.Forms.Clipboard]::SetDataObject($clipboardBackup, $true)
            }
        } else {
            $clipboardMode = 'clear'
            $restoreClipboard = {
                [System.Windows.Forms.Clipboard]::Clear()
            }
        }
    } catch {
        $result = New-ValidationResult -Ok $false -Status 'skipped' -Message 'Skipped mutate validation because clipboard state could not be backed up safely.' -Extra @{
            clipboard_mode = 'unavailable'
            detail = $_.Exception.Message
        }
        $result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $resultFile -Encoding UTF8
        $result | ConvertTo-Json -Depth 8
        exit 0
    }

    [System.Windows.Forms.Application]::EnableVisualStyles()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $windowTitle
    $form.StartPosition = 'CenterScreen'
    $form.Width = 720
    $form.Height = 520
    $form.TopMost = $true
    $form.ShowInTaskbar = $true
    $form.FormBorderStyle = 'Sizable'

    $instructions = New-Object System.Windows.Forms.Label
    $instructions.AutoSize = $false
    $instructions.Dock = 'Top'
    $instructions.Height = 80
    $instructions.Text = "EasyTouch local mutation validation fixture. This window is created by the repo-owned PowerShell verifier and should receive exactly one guarded paste operation."
    $instructions.Padding = New-Object System.Windows.Forms.Padding(12)
    $form.Controls.Add($instructions)

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Multiline = $true
    $textbox.AcceptsReturn = $true
    $textbox.AcceptsTab = $true
    $textbox.Dock = 'Fill'
    $textbox.Font = New-Object System.Drawing.Font('Consolas', 12)
    $form.Controls.Add($textbox)

    $companion = New-Object System.Windows.Forms.Form
    $companion.Text = $companionTitle
    $companion.StartPosition = 'Manual'
    $companion.Left = 1080
    $companion.Top = 420
    $companion.Width = 440
    $companion.Height = 260
    $companion.TopMost = $true
    $companion.ShowInTaskbar = $true
    $companion.FormBorderStyle = 'Sizable'

    $companionLabel = New-Object System.Windows.Forms.Label
    $companionLabel.AutoSize = $false
    $companionLabel.Dock = 'Fill'
    $companionLabel.Padding = New-Object System.Windows.Forms.Padding(12)
    $companionLabel.Text = "Companion window for pid-filtered window listing and handle-based activation validation."
    $companion.Controls.Add($companionLabel)

    $state = [ordered]@{
        attempts = 0
        wrong_guard = $null
        foreground_result = $null
        pid_filtered_window_list = $null
        activation_to_companion = $null
        activation_back_to_editor = $null
        clipboard_set = $null
        clipboard_get = $null
        guarded_paste = $null
        textbox_value = $null
        failure = $null
    }

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 250
    $phase = 0

    $timer.Add_Tick({
        try {
            switch ($script:phase) {
                0 {
                    Focus-FixtureWindow -Window $form -FocusControl $textbox
                    $state.foreground_result = (Invoke-EasyTouchJson -Arguments @('window', 'foreground', '--output', 'json')).Json

                    $windowList = Invoke-EasyTouchJson -Arguments @('window', 'list', '--pid', "$PID", '--output', 'json')
                    if (-not $windowList.Json.ok) {
                        throw "window list --pid failed. $($windowList.Raw)"
                    }

                    $listedWindows = @($windowList.Json.data.windows)
                    if ($listedWindows.Count -lt 2) {
                        throw "window list --pid returned only $($listedWindows.Count) windows for pid $PID."
                    }
                    if (@($listedWindows | Where-Object { $_.pid -ne $PID }).Count -ne 0) {
                        throw 'window list --pid returned a window from another process.'
                    }

                    $editorWindow = $listedWindows | Where-Object { $_.title -eq $windowTitle } | Select-Object -First 1
                    $companionWindow = $listedWindows | Where-Object { $_.title -eq $companionTitle } | Select-Object -First 1
                    if (-not $editorWindow) {
                        throw "window list --pid did not include the editor fixture window '$windowTitle'."
                    }
                    if (-not $companionWindow) {
                        throw "window list --pid did not include the companion fixture window '$companionTitle'."
                    }

                    $editorHandle = [uint64]$form.Handle.ToInt64()
                    $companionHandle = [uint64]$companion.Handle.ToInt64()
                    if ([uint64]$editorWindow.handle -ne $editorHandle) {
                        throw "window list --pid returned handle $($editorWindow.handle) for the editor fixture instead of $editorHandle."
                    }
                    if ([uint64]$companionWindow.handle -ne $companionHandle) {
                        throw "window list --pid returned handle $($companionWindow.handle) for the companion fixture instead of $companionHandle."
                    }
                    $state.pid_filtered_window_list = $windowList.Json

                    $activateCompanion = Invoke-EasyTouchJson -Arguments @('window', 'activate', '--handle', ('0x{0:x}' -f [uint64]$companionWindow.handle), '--output', 'json')
                    if (-not $activateCompanion.Json.ok) {
                        throw "window activate failed for the companion fixture. $($activateCompanion.Raw)"
                    }
                    $state.activation_to_companion = [ordered]@{
                        activate = $activateCompanion.Json
                        foreground = Wait-ForForegroundTitle -ExpectedTitle $companionTitle -Attempts 12 -DelayMs 150
                    }

                    $activateEditor = Invoke-EasyTouchJson -Arguments @('window', 'activate', '--handle', "$($editorWindow.handle)", '--output', 'json')
                    if (-not $activateEditor.Json.ok) {
                        throw "window activate failed for the editor fixture. $($activateEditor.Raw)"
                    }
                    $state.activation_back_to_editor = [ordered]@{
                        activate = $activateEditor.Json
                        foreground = Wait-ForForegroundTitle -ExpectedTitle $windowTitle -Attempts 12 -DelayMs 150
                    }

                    Focus-FixtureWindow -Window $form -FocusControl $textbox

                    $set = Invoke-EasyTouchJson -Arguments @('clipboard', 'set-text', '--text', $sentinel, '--output', 'json')
                    if (-not $set.Json.ok) {
                        throw "clipboard set-text failed. $($set.Raw)"
                    }
                    $state.clipboard_set = $set.Json

                    $get = Invoke-EasyTouchJson -Arguments @('clipboard', 'get-text', '--output', 'json')
                    if (-not $get.Json.ok) {
                        throw "clipboard get-text failed after set-text. $($get.Raw)"
                    }
                    if ($get.Json.data.text -ne $sentinel) {
                        throw "clipboard get-text returned '$($get.Json.data.text)' instead of the sentinel payload."
                    }
                    $state.clipboard_get = $get.Json

                    $wrong = Invoke-EasyTouchJson -Arguments @('keyboard', 'paste', '--expect-title', $wrongGuard, '--match', 'exact', '--output', 'json')
                    if ($wrong.Json.ok) {
                        throw "Guarded paste unexpectedly succeeded for a mismatched title. $($wrong.Raw)"
                    }
                    if ($wrong.Json.failure.code -ne 'unsafe_operation') {
                        throw "Guarded paste mismatch returned '$($wrong.Json.failure.code)' instead of unsafe_operation."
                    }
                    if (-not [string]::IsNullOrEmpty($textbox.Text)) {
                        throw 'The textbox changed during the mismatched guarded-paste check.'
                    }
                    $state.wrong_guard = $wrong.Json

                    $reassertEditor = Invoke-EasyTouchJson -Arguments @('window', 'activate', '--handle', "$($editorWindow.handle)", '--output', 'json')
                    if (-not $reassertEditor.Json.ok) {
                        throw "window activate failed while reasserting the editor fixture before paste. $($reassertEditor.Raw)"
                    }
                    [void](Wait-ForForegroundTitle -ExpectedTitle $windowTitle -Attempts 12 -DelayMs 150)
                    Focus-FixtureWindow -Window $form -FocusControl $textbox

                    $paste = Invoke-EasyTouchJson -Arguments @('keyboard', 'paste', '--expect-title', $windowTitle, '--match', 'exact', '--output', 'json')
                    if (-not $paste.Json.ok) {
                        throw "Guarded paste failed for the exact fixture title. $($paste.Raw)"
                    }
                    $state.guarded_paste = $paste.Json
                    $script:phase = 1
                }
                1 {
                    if ($textbox.Text -eq $sentinel) {
                        $state.textbox_value = $textbox.Text
                        $timer.Stop()
                        $form.Close()
                        return
                    }

                    $state.attempts += 1
                    if ($state.attempts -ge 12) {
                        throw "Textbox never received the sentinel text. Current value: '$($textbox.Text)'"
                    }
                }
            }
        } catch {
            $state.failure = $_.Exception.Message
            $timer.Stop()
            $form.Close()
        }
    })

    $form.Add_Shown({
        $companion.Show()
        $companion.Refresh()
        Start-Sleep -Milliseconds 150
        Focus-FixtureWindow -Window $form -FocusControl $textbox
        $timer.Start()
    })

    $form.Show()
    [System.Windows.Forms.Application]::Run($form)

    if ($state.failure) {
        throw $state.failure
    }

    $result = New-ValidationResult -Ok $true -Status 'validated' -Message 'Safe window activation, pid-filtered listing, clipboard, and guarded paste validation succeeded.' -Extra @{
        clipboard_mode = $clipboardMode
        fixture_window_title = $windowTitle
        companion_window_title = $companionTitle
        sentinel = $sentinel
        checks = [ordered]@{
            foreground_window = $state.foreground_result
            pid_filtered_window_list = $state.pid_filtered_window_list
            activation_to_companion = $state.activation_to_companion
            activation_back_to_editor = $state.activation_back_to_editor
            clipboard_set = $state.clipboard_set
            clipboard_get = $state.clipboard_get
            guarded_paste_mismatch = $state.wrong_guard
            guarded_paste_match = $state.guarded_paste
            textbox_value = $state.textbox_value
        }
    }

    $result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $resultFile -Encoding UTF8
    $result | ConvertTo-Json -Depth 8
} finally {
    try {
        if ($companion -and -not $companion.IsDisposed) {
            $companion.Close()
        }
    } catch {
    }

    try {
        & $restoreClipboard
    } catch {
        $restoreFailure = New-ValidationResult -Ok $false -Status 'restore_failed' -Message 'Validation finished but clipboard restore failed.' -Extra @{
            clipboard_mode = $clipboardMode
            detail = $_.Exception.Message
        }
        $restoreFailure | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $resultFile -Encoding UTF8
        $restoreFailure | ConvertTo-Json -Depth 8
        exit 1
    }
}

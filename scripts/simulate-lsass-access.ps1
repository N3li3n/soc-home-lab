# simulate-lsass-access.ps1
# Симуляция доступа к LSASS для тестирования правила 100710/100711.
# Запуск: powershell.exe -ExecutionPolicy Bypass -File .\simulate-lsass-access.ps1

$sig = @'
[DllImport("kernel32.dll")]
public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, uint dwProcessId);
'@

$kernel32 = Add-Type -MemberDefinition $sig -Name 'Kernel32' -Namespace 'Win32' -PassThru

$lsassId = (Get-Process lsass).Id
Write-Host "[*] LSASS PID: $lsassId"

# 0x1FFFFF = PROCESS_ALL_ACCESS (аналогично ProcDump)
$handle = $kernel32::OpenProcess(0x1FFFFF, $false, $lsassId)
Write-Host "[*] Handle opened: $handle"

if ($handle -ne [IntPtr]::Zero) {
    Write-Host "[+] Successfully opened LSASS handle"
} else {
    Write-Host "[-] Failed to open LSASS handle (run as Administrator)"
}

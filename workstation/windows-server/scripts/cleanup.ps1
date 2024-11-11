Write-Host "Cleaning updates.." -ForegroundColor 'Cyan'
Stop-Service -Name wuauserv -Force
Remove-Item c:\Windows\SoftwareDistribution\Download\* -Recurse -Force
Start-Service -Name wuauserv

Write-Host "Cleaning SxS..." -ForegroundColor 'Cyan'
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

@(
    "$env:localappdata\Nuget",
    "$env:localappdata\temp\*",
    "$env:windir\logs",
    "$env:windir\panther",
    "$env:windir\temp\*",
    "$env:windir\winsxs\manifestcache"
) | ForEach-Object {
    if (Test-Path $_) {
        Write-Host "Removing $_"
        try {
            Takeown /d Y /R /f $_
            Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
            Remove-Item $_ -Recurse -Force | Out-Null
        }
        catch { $global:error.RemoveAt(0) }
    }
}

Write-Host "defragging..." -ForegroundColor 'Cyan'
if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) {
    Optimize-Volume -DriveLetter C
}
else {
    Defrag.exe c: /H
}
fsutil behavior set DisableDeleteNotify 0

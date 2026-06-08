Clear-Host

Write-Host "========================================="
Write-Host " DISCOS CONECTADOS"
Write-Host "========================================="

Get-CimInstance Win32_LogicalDisk |
Select-Object `
@{Name="Disco"; Expression={$_.DeviceID}},
@{
    Name="Tipo de Dispositivo"
    Expression={
        switch ($_.DriveType) {
            2 { "Disco removible" }
            3 { "Disco local" }
            4 { "Unidad de red" }
            5 { "CD/DVD" }
            6 { "RAM Disk" }
            default { "Desconocido" }
        }
    }
},
@{Name="Espacio Total (bytes)"; Expression={"{0:N0}" -f $_.Size}},
@{Name="Espacio Libre (bytes)"; Expression={"{0:N0}" -f $_.FreeSpace}} |
Format-Table -AutoSize

Pause
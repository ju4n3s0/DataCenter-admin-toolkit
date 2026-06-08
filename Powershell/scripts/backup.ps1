Clear-Host

Write-Host "========================================="
Write-Host " BACKUP A MEMORIA USB"
Write-Host "========================================="

$origen = Read-Host "Ingrese el directorio a respaldar (Ej: C:\Datos): "

$usb = Read-Host "Ingrese la unidad USB destino (Ej: E:): "

$destino = Join-Path $usb "Backup"

Write-Host "Realizando copia de seguridad..."

#Aqui se crea el directorio destinto, si ya existe no se borra nada
New-Item -ItemType Directory -Path $destino -Force | Out-Null

#Agregue el force para que no haya problemas con cosas ocultas
Copy-Item -Path $origen -Destination $destino -Recurse -Force

$catalogo = Join-Path $destino "catalogo.txt"

Get-ChildItem -Path $origen -File -Recurse |
ForEach-Object {
    "$($_.FullName) | $($_.LastWriteTime)"
} | Out-File $catalogo

Write-Host "Backup completado correctamente."
Write-Host "Catalogo generado en:"
Write-Host $catalogo

Pause
Clear-Host

Write-Host "========================================="
Write-Host " DIEZ ARCHIVOS MAS GRANDES"
Write-Host "========================================="

$disco = Read-Host "Ingrese el disco a analizar (Ej: C:)"

Write-Host "Buscando archivos... Esto puede tardar un buen rato."

#Agregue el -ErrorAction SilentlyContinue por si sale un error al intentar entrar a una carpeta protegida
Get-ChildItem -Path "$disco\" -File -Recurse -ErrorAction SilentlyContinue |
Sort-Object Length -Descending |
Select-Object -First 10 `
@{Name="Tamano (bytes)"; Expression={"{0:N0}" -f $_.Length}},
@{Name="Ruta Completa"; Expression={$_.FullName}} |
Format-Table -AutoSize

Pause
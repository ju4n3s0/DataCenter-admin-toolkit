Clear-Host

Write-Host "========================================="
Write-Host " MEMORIA Y SWAP"
Write-Host "========================================="

$os = Get-CimInstance Win32_OperatingSystem

$memoriaLibre = $os.FreePhysicalMemory * 1KB
$memoriaTotal = $os.TotalVisibleMemorySize * 1KB

$swapTotal = ($os.SizeStoredInPagingFiles) * 1KB
$swapLibre = ($os.FreeSpaceInPagingFiles) * 1KB
$swapUsado = $swapTotal - $swapLibre

$porcentajeMemoriaLibre = ($memoriaLibre / $memoriaTotal) * 100

if ($swapTotal -gt 0) {
    $porcentajeSwapUsado = ($swapUsado / $swapTotal) * 100
}
else {
    $porcentajeSwapUsado = 0
}

Write-Host ("Memoria libre: {0:N0} bytes ({1:N2}%)" -f $memoriaLibre, $porcentajeMemoriaLibre)
Write-Host ("Swap en uso:   {0:N0} bytes ({1:N2}%)" -f $swapUsado,$porcentajeSwapUsado)

Pause
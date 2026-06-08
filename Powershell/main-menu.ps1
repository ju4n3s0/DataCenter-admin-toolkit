function MostrarMenuPrincipal
{
    Clear-Host

    Write-Host "========================================="
    Write-Host " HERRAMIENTAS DE ADMINISTRACION"
    Write-Host "========================================="
    Write-Host ""
    Write-Host "1. Mostrar usuarios y ultimo login"
    Write-Host "2. Mostrar discos conectados"
    Write-Host "3. Mostrar diez archivos mas grandes"
    Write-Host "4. Mostrar memoria libre y uso de swap"
    Write-Host "5. Realizar backup a memoria USB"
    Write-Host "0. Salir"
    Write-Host ""
}

#Loop principal del programa
do
{
    MostrarMenuPrincipal

    $opcionSeleccionada = Read-Host "Seleccione una opcion"

    switch ($opcionSeleccionada)
    {
        "1"{& ".\scripts\usuarios.ps1"}
        "2"{ & ".\scripts\discos.ps1"}
        "3"{ & ".\scripts\archivos-grandes.ps1"}
        "4"{& ".\scripts\memoria.ps1"}
        "5"{& ".\scripts\backup.ps1"}

        "0"
        {
            Write-Host ""
            Write-Host "Bye byeee..."
        }

        default
        {
            Write-Host ""
            Write-Host "Opcion invalida. Elija uno de los numeros del menu."
            Pause
        }
    }

} while ($opcionSeleccionada -ne "0")
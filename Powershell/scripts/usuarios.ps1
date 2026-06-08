Clear-Host

Write-Host "========================================="
Write-Host " USUARIOS Y ULTIMO LOGIN"
Write-Host "========================================="

$usuariosSistema = Get-CimInstance -ClassName Win32_UserAccount |
    Where-Object { $_.LocalAccount -eq $true }

$sesionesActivas = quser | Select-Object -Skip 1

foreach ($usuario in $usuariosSistema)
{
    $ultimoLogin = "Nunca"

    foreach ($sesion in $sesionesActivas)
    {
        $sesionLimpia = $sesion.TrimStart(">")

        if ($sesionLimpia -match "^(\S+)")
        {
            $nombreUsuarioSesion = $matches[1]

            if ($nombreUsuarioSesion -eq $usuario.Name)
            {
                if ($sesionLimpia -match "(\d{1,2}/\d{1,2}/\d{4}\s+\d{1,2}:\d{2}\s+[AP]M)")
                {
                    $ultimoLogin = $matches[1]
                }

                break
            }
        }
    }

    Write-Host "Usuario: $($usuario.Name)"
    Write-Host "Ultimo login: $ultimoLogin"
    Write-Host ""
}

Pause

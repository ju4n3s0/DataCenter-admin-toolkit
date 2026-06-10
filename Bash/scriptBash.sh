main_menu(){
	clear
	while true; do
		echo " ===========BIENVENIDO================"
		echo " ===HERRAMIENTA DE ADMINISTRACIÓN====="
		echo " ====================================="   
		echo ""
        echo " =========MENU PRINCIPAL=============="   
		echo ""
		echo " 1. Usuarios del sistema y último login"
		echo " 2. Filesystems / Discos conectados"
		echo " 3. Los 10 archios más grandes en un filesystem"
		echo " 4. Memoria libre y swap en uso"
		echo " 5. Copia de seguridad (backup) a USB"
		echo " 6. Salir"
	
		read -r choice
	
		case "$choice" in 
			1) option_1Users ;;
			2) option_2Disks ;;
			3) option_3BigFiles ;;
			4) option_4Memoria ;;
			5) option_5BackUp ;;
			6) clear 
				echo "Hasta luego señor Stark"
				echo ""
				exit 0 ;;
			*) echo "Opción inválida" ;;
		esac
	done		
}

#pause para que se mantenga en curso
pause() {
    echo ""
    echo "Presione ENTER o Cualquier letra para continuar..."
    read -r
	clear
}

#Opción 1 
option_1Users(){
	clear
	echo ""
	echo ""
    echo " ===========OPCIÓN 1================"
	echo "Usuarios del sistema y su último login"
	echo ""
	local user_list
	user_list=$(dscl . -list /Users UniqueID 2>/dev/null | awk '$2 >= 500 || $2 == 0 {print $1, $2}')

	local count=0
	while read -r username uid; do
		# Saltar cuentas de servicio (empiezan con _) y nobody
		[[ "$username" == _* || "$username" == "nobody" ]] && continue

		# Obtener último login con 'last'
		local last_login last_term
		local l_line
		l_line=$(last -1 "$username" 2>/dev/null | head -1)
		
		printf "  %-20s %-12s %-20s %-15s\n" \
				"$username" "$uid" "$last_login" "$last_term"
		(( count++ ))
	done <<< "$user_list"

	echo ""
	echo "Total usuarios mostrados: ${count}"
	pause
}

#Opción 2
option_2Disks(){
	clear
	echo ""
	echo ""
    echo " ===========OPCIÓN 2================"
	echo "Filesystems y discos conectados"
	echo ""

    printf "%-35s %-18s %-18s %-6s\n" "FILESYSTEM" "tamano (bytes)" "LIBRE (bytes)" "USO%"
    echo "$LINEA"

    df -k 2>/dev/null | tail -n +2 | while read -r fs bloques_1k usados libres pct punto; do

        # Filtramos pseudo-filesystems de la mac
        case "$fs" in
            devfs|map*|none|tmpfs)
                continue
                ;;
        esac

        if ! [[ "$bloques_1k" =~ ^[0-9]+$ ]]; then
            continue
        fi

        tamano_bytes=$(( bloques_1k * 1024 ))
        libres_bytes=$(( libres * 1024 ))

        if [[ "$tamano_bytes" -eq 0 ]]; then
            continue
        fi

        printf "%-35s %-18s %-18s %-6s\n" "$fs" "$tamano_bytes" "$libres_bytes" "$pct"

    done
	echo " Los tamanos están expresados en Bytes y los pseudo systemas no están incluidos"

	pause
}

#Opción 3 para ver los 10 archivos más grandes 
option_3BigFiles(){
	clear
	echo ""
	echo ""
    echo " ===========OPCIÓN 3================"
	echo "Filesystems y discos conectados"
	echo ""

	echo "Puntos de montaje disponibles:"
    echo ""
    df -k 2>/dev/null | tail -n +2 | while read -r fs _ _ _ _ punto; do
        case "$fs" in
            devfs|map*|none|tmpfs)
                continue
                ;;
        esac
        echo "$punto"
    done

    echo ""
    echo -n "Ingrese la ruta del disco o directorio a analizar: "
    read -r ruta

    if [[ -z "$ruta" ]]; then
        echo ""
        echo "No ingresó ninguna ruta señor stark"
        pause
        return
    fi

    if [[ ! -e "$ruta" ]]; then
        echo ""
        echo "La ruta '$ruta' no existe."
        pause
        return
    fi

    if [[ ! -d "$ruta" ]]; then
        echo ""
        echo "'$ruta' no es un directorio."
        pause
        return
    fi

    echo ""
    echo "Buscando los 10 archivos mas grandes en: $ruta"
    echo "Esto puede tardar un momento..."
    echo ""

    # En la mac, stat usa -f "%z %N" para tamano y nombre
    resultados=$(find "$ruta" -type f 2>/dev/null \
        -exec stat -f "%z %N" {} \; 2>/dev/null \
        | sort -rn \
        | head -10)

    if [[ -z "$resultados" ]]; then
        echo "No se encontraron archivos en '$ruta'."
        pause
        return
    fi

    printf "%-15s %-s\n" "tamano (bytes)" "RUTA COMPLETA"

    echo "-------------------------------------------------"
	
    echo "$resultados" | while read -r tamano ruta_archivo; do
        printf "%-15s %-s\n" "$tamano" "$ruta_archivo"
    done

    echo ""
    pause
}

#Opción 4 Memoria libre y swap en uso
option_4Memoria(){
	clear
	echo ""
	echo ""
    echo " ===========OPCIÓN 4================"
	echo "Memoria libre y swap en uso"
	echo ""
	if ! command -v vm_stat &>/dev/null; then
        echo " El comando 'vm_stat' no esta disponible."
        pause
        return
    fi

    # En Apple Silicon el tamano de pagina es 16384 bytes
    tamano_pagina=$(pagesize 2>/dev/null)
    if [[ -z "$tamano_pagina" || ! "$tamano_pagina" =~ ^[0-9]+$ ]]; then
        tamano_pagina=16384
    fi

    vm_salida=$(vm_stat 2>/dev/null)

    if [[ -z "$vm_salida" ]]; then
        echo " No se pudo obtener informacion de memoria con vm_stat."
        pause

        return
    fi

    paginas_libres=$(echo "$vm_salida"      | awk '/Pages free/                    {gsub(/\./,"",$NF); print $NF+0}')
    paginas_activas=$(echo "$vm_salida"     | awk '/Pages active/                  {gsub(/\./,"",$NF); print $NF+0}')
    paginas_inactivas=$(echo "$vm_salida"   | awk '/Pages inactive/                {gsub(/\./,"",$NF); print $NF+0}')
    paginas_wired=$(echo "$vm_salida"       | awk '/Pages wired down/              {gsub(/\./,"",$NF); print $NF+0}')
    paginas_comprimidas=$(echo "$vm_salida" | awk '/Pages occupied by compressor/  {gsub(/\./,"",$NF); print $NF+0}')

    paginas_libres=${paginas_libres:-0}
    paginas_activas=${paginas_activas:-0}
    paginas_inactivas=${paginas_inactivas:-0}
    paginas_wired=${paginas_wired:-0}
    paginas_comprimidas=${paginas_comprimidas:-0}

    mem_libre=$(( paginas_libres * tamano_pagina ))
    mem_activa=$(( paginas_activas * tamano_pagina ))
    mem_inactiva=$(( paginas_inactivas * tamano_pagina ))
    mem_wired=$(( paginas_wired * tamano_pagina ))
    mem_comprimida=$(( paginas_comprimidas * tamano_pagina ))
    mem_total=$(( (paginas_libres + paginas_activas + paginas_inactivas + paginas_wired + paginas_comprimidas) * tamano_pagina ))
    mem_usada=$(( mem_activa + mem_wired + mem_comprimida ))

    if [[ "$mem_total" -gt 0 ]]; then
        pct_libre=$(( (mem_libre * 100) / mem_total ))
        pct_usada=$(( (mem_usada * 100) / mem_total ))
    else
        pct_libre=0
        pct_usada=0
    fi

    echo "--- MEMORIA RAM ---"
    echo ""
    printf "%-35s %s bytes\n"           "Memoria total:"          "$mem_total"
    printf "%-35s %s bytes  (%s%%)\n"   "Memoria libre:"          "$mem_libre"    "$pct_libre"
    printf "%-35s %s bytes  (%s%%)\n"   "Memoria en uso:"         "$mem_usada"    "$pct_usada"
    printf "%-35s %s bytes\n"           "  Activa:"               "$mem_activa"
    printf "%-35s %s bytes\n"           "  Reservada (wired):"    "$mem_wired"
    printf "%-35s %s bytes\n"           "  Comprimida:"           "$mem_comprimida"
    printf "%-35s %s bytes\n"           "  Inactiva:"             "$mem_inactiva"

    echo ""
    echo "--- SWAP ---"
    echo ""

    if ! command -v sysctl &>/dev/null; then
        echo "El comando 'sysctl' no esta disponible. No se puede leer el swap."
    else
        swap_linea=$(sysctl vm.swapusage 2>/dev/null)

        if [[ -z "$swap_linea" ]]; then
            echo "No se pudo obtener informacion del swap."
        else
            swap_total_m=$(echo "$swap_linea" | sed -n 's/.*total = \([0-9.]*\)M.*/\1/p')
            swap_usado_m=$(echo "$swap_linea" | sed -n 's/.*used = \([0-9.]*\)M.*/\1/p')
            swap_libre_m=$(echo "$swap_linea" | sed -n 's/.*free = \([0-9.]*\)M.*/\1/p')

            swap_total_m=${swap_total_m:-0}
            swap_usado_m=${swap_usado_m:-0}
            swap_libre_m=${swap_libre_m:-0}

            swap_total_b=$(awk "BEGIN {printf \"%.0f\", $swap_total_m * 1048576}")
            swap_usado_b=$(awk "BEGIN {printf \"%.0f\", $swap_usado_m * 1048576}")
            swap_libre_b=$(awk "BEGIN {printf \"%.0f\", $swap_libre_m * 1048576}")

            if [[ "$swap_total_b" -gt 0 ]]; then
                pct_swap=$(awk "BEGIN {printf \"%.1f\", ($swap_usado_b * 100) / $swap_total_b}")
            else
                pct_swap="0.0"
            fi

            printf "%-35s %s bytes\n" "Swap total:" "$swap_total_b"
            printf "%-35s %s bytes  (%s%%)\n" "Swap en uso:" "$swap_usado_b" "$pct_swap"
            printf "%-35s %s bytes\n" "Swap libre:" "$swap_libre_b"
        fi
    fi

    echo ""
    pause

}

option_5BackUp(){
	clear
	echo ""
	echo ""
    echo " ===========OPCIÓN 5================"
	echo "Memoria libre y swap en uso"
	echo ""

	echo "Volumenes disponibles en /Volumes:"
    echo ""

    if [[ ! -d /Volumes ]]; then
        echo "No se encontro el directorio /Volumes."
        echo "Debera ingresar la ruta manualmente."
    else
        count_vol=0
        for vol in /Volumes/*/; do
            if [[ -d "$vol" ]]; then
                echo "  $vol"
                count_vol=$(( count_vol + 1 ))
            fi
        done

        if [[ "$count_vol" -eq 0 ]]; then
            echo "No se encontraron volumenes montados."
        fi
    fi

    echo ""
    echo -n "Directorio a respaldar (ruta completa): "
    read -r origen

    if [[ -z "$origen" ]]; then
        echo ""
        echo "No ingreso ninguna ruta de origen."
        pause
        return
    fi

    if [[ ! -e "$origen" ]]; then
        echo ""
        echo "El directorio '$origen' no existe."
        pause
        return
    fi

    if [[ ! -d "$origen" ]]; then
        echo ""
        echo " '$origen' no es un directorio."
        pause
        return
    fi

    echo -n "Ruta de la memoria USB destino (ej: /Volumes/MiUSB): "
    read -r destino_usb

    if [[ -z "$destino_usb" ]]; then
        echo ""
        echo "No ingreso ninguna ruta de destino."
        pause
        return
    fi

    if [[ ! -e "$destino_usb" ]]; then
        echo ""
        echo "La ruta '$destino_usb' no existe o la USB no esta montada."
        pause
        return
    fi

    if [[ ! -d "$destino_usb" ]]; then
        echo ""
        echo "'$destino_usb' no es un directorio."
        pause
        return
    fi

    if [[ ! -w "$destino_usb" ]]; then
        echo ""
        echo "No tiene permisos de escritura en '$destino_usb'."
        pause
        return
    fi

    timestamp=$(date '+%Y%m%d_%H%M%S')
    nombre_origen=$(basename "$origen")
    directorio_backup="${destino_usb}/backup_${nombre_origen}_${timestamp}"

    echo ""
    echo "Creando directorio de backup..."

    if ! mkdir -p "$directorio_backup"; then
        echo ""
        echo "No se pudo crear el directorio '$directorio_backup'."
        pause
        return
    fi

    echo "Copiando archivos..."

    archivos_copiados=0
    archivos_con_error=0

    while IFS= read -r archivo; do

        ruta_relativa="${archivo#$origen/}"
        destino_archivo="${directorio_backup}/${ruta_relativa}"
        directorio_destino=$(dirname "$destino_archivo")

        if [[ ! -d "$directorio_destino" ]]; then
            mkdir -p "$directorio_destino" 2>/dev/null
        fi

        if cp -p "$archivo" "$destino_archivo" 2>/dev/null; then
            archivos_copiados=$(( archivos_copiados + 1 ))
        else
            archivos_con_error=$(( archivos_con_error + 1 ))
        fi

    done < <(find "$origen" -type f 2>/dev/null)

    catalogo="${directorio_backup}/CATALOGO_${timestamp}.txt"
    echo "Generando catalogo..."

    {
        echo "  CATALOGO DE BACKUP"
        echo "============================================================"
        echo "  Origen    : $origen"
        echo "  Destino   : $directorio_backup"
        echo "  Fecha/Hora: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "  Host      : $(hostname)"
        echo "  Usuario   : $(whoami)"
        echo "============================================================"
        echo ""
        printf "%-50s %-25s %-12s\n" "ARCHIVO (ruta relativa)" "ULTIMA MODIFICACION" "tamano (B)"
        echo "------------------------------------------------------------"

        while IFS= read -r archivo; do
            ruta_relativa="${archivo#$origen/}"
            fecha_mod=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$archivo" 2>/dev/null)
            tamano=$(stat -f "%z" "$archivo" 2>/dev/null)

            if [[ -z "$fecha_mod" ]]; then fecha_mod="Sin informacion"; fi
            if [[ -z "$tamano"   ]]; then tamano="0"; fi

            printf "%-50s %-25s %-12s\n" "$ruta_relativa" "$fecha_mod" "$tamano"

        done < <(find "$origen" -type f 2>/dev/null)

        echo ""
        echo "  Total de archivos copiados : $archivos_copiados"
        echo "  Archivos con error         : $archivos_con_error"

    } > "$catalogo"

    if [[ ! -f "$catalogo" ]]; then
        echo "ADVERTENCIA: El catalogo no se pudo generar."
    fi
    echo ""
    echo "BACKUP COMPLETADO"
    echo "============================================================"
    echo "  Origen              : $origen"
    echo "  Destino             : $directorio_backup"
    echo "  Catalogo            : $catalogo"
    echo "  Archivos copiados   : $archivos_copiados"
    if [[ "$archivos_con_error" -gt 0 ]]; then
        echo "  Archivos con error  : $archivos_con_error (verifique permisos)"
    fi
    echo "============================================================"
    echo ""
    pause
}

main_menu
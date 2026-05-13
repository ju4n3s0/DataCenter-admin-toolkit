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
			6) clear 
			   echo "Hasta luego"
			   echo ""
			   exit 0 ;;
			*) echo "Opción inválida" ;;
		esac
	done		
}

option_1Users(){
	clear
	echo ""
	echo ""
        echo " ===========OPCIÓN 1================"
	echo "Usuarios del sistema y su último login"
	echo ""
	local user_list
	user_list=$(dscl . -list /Users UniqueID)

	local count 
	while 
}

main_menu
 


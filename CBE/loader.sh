#!/bin/bash

## USER SET
CBE_CORE_INSTALL_PATH="/path/to/CBE"

CBE_CORE_GLOBAL_MODULES_PATH="$CBE_CORE_INSTALL_PATH"/modules
CBE_CORE_SYSTEM_MODULES_PATH="$CBE_CORE_INSTALL_PATH"/core
CBE_CORE_USER_MODULES_PATH="$HOME"/.cbe_modules
CBE_CORE_TMP_PATH="/tmp"

declare -A CBE_CORE_MODULE_UUID_TABLE

CBE_UUID=""

CBE_CORE_SETTING_BOOL_QUIETMODE=""
CBE_CORE_SETTING_BOOL_FLATFILE=""

CBE_CORE_VERSION="v0.0.3"

function CBE.Loader.ShowIntro()
{
	CBE.Loader.PrintMessageNewLine "##"
	CBE.Loader.PrintMessageNewLine "# == Chicken's Bash Extensions =="
	CBE.Loader.PrintMessageNewLine "#	- Version $CBE_CORE_VERSION -"
	CBE.Loader.PrintMessageNewLine "#"
	CBE.Loader.PrintMessageNewLine "# - All extension commands are prefixed with '@'. -"
	CBE.Loader.PrintMessageNewLine "#"
}

## MODULE LOADING FUNCTIONS

## Initialize Modules
function CBE.Loader.LoadModules()
{
	## Check if we are using flatfile mode
	if [ "$CBE_CORE_SETTING_BOOL_FLATFILE" == "true" ]; then
		CBE.Loader.LoadFlatFile
	fi
	
	CBE_CORE_TMP_LAST_DIR="$(pwd)"
	
	CBE.Loader.LoadSystemModules
	
	CBE.Loader.LoadGlobalModules
	
	CBE.Loader.LoadUserModules
		
	cd "$CBE_CORE_TMP_LAST_DIR"
	
	CBE.Loader.PrintMessageNewLine "# - Module Load Complete -"
	
	CBE.Loader.PrintMessageNewLine "##"
	
}

function CBE.Loader.LoadSystemModules()
{
	CBE.Loader.PrintMessage "# - Loading System Modules ... "
	
	CBE.Loader.LoadSystemModule "api.cbe"
	
	CBE.Loader.LoadSystemModule "system.cbe"
	
	CBE.Loader.LoadSystemModule "help.cbe"
	
	CBE.Loader.PrintMessageNewLine " Ok!"
}

function CBE.Loader.LoadGlobalModules()
{
	CBE.Loader.PrintMessageNewLine "# - Loading Global Modules : "
		
	cd "$CBE_CORE_GLOBAL_MODULES_PATH"
	
	for f in *.cbe; do 
		if [ "$f" == "*.cbe" ]; then
			CBE.Loader.PrintMessageNewLine "#   - WARN: No global modules found."
		else
			CBE.Loader.PrintMessage "#   - Global Module: ${f%.*} ... "
			
			CBE.Loader.LoadModule "$CBE_CORE_GLOBAL_MODULES_PATH" "$f"
			
			if [ -d "$CBE_CORE_GLOBAL_MODULES_PATH"/${f%.*} ]; then
					
				CBE.Loader.PrintMessageNewLine "#       - Loading Sub-Modules For  ... "
					
				cd "$CBE_CORE_GLOBAL_MODULES_PATH"/${f%.*}
					
				for sf in *.cbe; do 
					if [ "$sf" == "*.cbe" ]; then
						CBE.Loader.PrintMessageNewLine "#           - WARN: No sub-modules found."
					else
						CBE.Loader.LoadSubModule ""$CBE_CORE_GLOBAL_MODULES_PATH"/${f%.*}" "$f" "$sf"
						CBE.Loader.PrintMessageNewLine "#           - ${sf%.*} ... Ok!"
					fi
				done		
			fi
		fi
	done
}

function CBE.Loader.LoadUserModules()
{
	CBE.Loader.PrintMessageNewLine "# - Loading User Modules : "
		
	if [ -d "$CBE_CORE_USER_MODULES_PATH" ]; then
		
		cd "$CBE_CORE_USER_MODULES_PATH"
	
		for f in *.cbe; do 
			if [ "$f" == "*.cbe" ]; then
				CBE.Loader.PrintMessageNewLine "#   - WARN: No user modules found."
			else
				CBE.Loader.PrintMessage "#   - User Module: ${f%.*} ... "
				
				CBE.Loader.LoadModule "$CBE_CORE_USER_MODULES_PATH" "$f"
				
				if [ -d "$CBE_CORE_USER_MODULES_PATH"/${f%.*} ]; then
					
					CBE.Loader.PrintMessageNewLine "#       - Loading Sub-Modules For ${f%.*} ... "
					
					cd "$CBE_CORE_USER_MODULES_PATH"/${f%.*}
					
					for sf in *.cbe; do 
						if [ "$sf" == "*.cbe" ]; then
							CBE.Loader.PrintMessageNewLine "#           - WARN: No sub-modules found."
						else
							CBE.Loader.LoadSubModule ""$CBE_CORE_USER_MODULES_PATH"/${f%.*}" "$f" "$sf"
							CBE.Loader.PrintMessageNewLine "#           - ${sf%.*} ... Ok!"
						fi
					done
				fi
			fi
		done
	else
	
		CBE.Loader.PrintMessageNewLine "#   - WARN: No user module folder found. Skipping..."
	
	fi

}

##
# Load a module. 
# Ex. CBE.Loader.LoadModule "FOLDER_PATH" "MODULE_NAME.cbe"
##
function CBE.Loader.LoadModule()
{
	## Generate UUID.
	CBE.API.Math.GenerateUUID
		
	## Add entry to the module UUID table. Filename as the key and the returned uuid as the value.
	CBE_CORE_MODULE_UUID_TABLE=( ["$2"]="$CBE_API_FUNCTION_RESULT")
	
	local LOCAL_MODULE_UUID="${CBE_CORE_MODULE_UUID_TABLE["$2"]}"
		
	cd "$1"
		
	sed "s/*CBE_UUID/$CBE_UUID/g" "$2" > "$CBE_CORE_TMP_PATH"/"$2".tmp
	sed "s/*MODULE_UUID/$LOCAL_MODULE_UUID/g" "$CBE_CORE_TMP_PATH"/"$2".tmp > "$CBE_CORE_TMP_PATH"/"$2".tmp.2
	
	. "$CBE_CORE_TMP_PATH"/"$2".tmp.2
	
	rm "$CBE_CORE_TMP_PATH"/"$2".*
		
	"$LOCAL_MODULE_UUID".Load
	"$LOCAL_MODULE_UUID".CleanUp
}

##
# Load a sub module. 
# Ex. CBE.Loader.LoadSubModule "FOLDER_PATH" "PARENT_MODULE_NAME.cbe" "SUB_MODULE_NAME.cbe"
##
function CBE.Loader.LoadSubModule()
{
	local LOCAL_MODULE_UUID="${CBE_CORE_MODULE_UUID_TABLE["$2"]}"
	
	cd "$1"
	
	sed "s/*CBE_UUID/$CBE_UUID/g" "$3" > "$CBE_CORE_TMP_PATH"/"$3".tmp
	sed "s/*MODULE_UUID/$LOCAL_MODULE_UUID/g" "$CBE_CORE_TMP_PATH"/"$3".tmp > "$CBE_CORE_TMP_PATH"/"$3".tmp.2
	
	. "$CBE_CORE_TMP_PATH"/"$3".tmp.2
	
	rm "$CBE_CORE_TMP_PATH"/"$3".*
	
}

##
# Load a system module.
# Ex. CBE.Loader.LoadSystemModule "SYS_MODULE_FILENAME"
##
function CBE.Loader.LoadSystemModule()
{
	cd "$CBE_CORE_SYSTEM_MODULES_PATH"
	
	sed "s/*CBE_UUID/$CBE_UUID/g" "$1" > "$CBE_CORE_TMP_PATH"/"$1".tmp
	
	. "$CBE_CORE_TMP_PATH"/"$1".tmp
	
	rm "$CBE_CORE_TMP_PATH"/"$1".*
	
	if [ -d "$CBE_CORE_SYSTEM_MODULES_PATH"/${1%.*} ]; then ## Check for system sub-modules.
		
		cd "$CBE_CORE_SYSTEM_MODULES_PATH"/${1%.*}
		
		for sf in *.cbe; do 
			if [ "$sf" == "*.cbe" ]; then
				CBE.Loader.PrintMessage "System sub-module folder found but no modules!"
			else
				sed "s/*CBE_UUID/$CBE_UUID/g" "$sf" > "$CBE_CORE_TMP_PATH"/"$sf".tmp
	
				. "$CBE_CORE_TMP_PATH"/"$sf".tmp
	
				rm "$CBE_CORE_TMP_PATH"/"$sf".*
			fi
		done
	fi
}

## END MODULE LOADING FUNCTIONS

function CBE.Loader.LoadFlatFile()
{
	CBE.Loader.PrintMessage "# - Loading flatfile ... " 
	
	if [ -e ~/.cbe_dir ]; then
		CBE_CORE_INSTALL_PATH=$(head -n 1 ~/.cbe_dir)
		
		CBE_CORE_GLOBAL_MODULES_PATH="$CBE_CORE_INSTALL_PATH"/modules ## Reset the modules dir with new install path from flatfile.
		CBE_CORE_SYSTEM_MODULES_PATH="$CBE_CORE_INSTALL_PATH"/core
		
		CBE.Loader.PrintMessageNewLine "Ok!"
	else
		CBE.Loader.PrintMessageNewLine "Fail!"
		CBE.Loader.PrintMessageNewLine "# (WARN) Flat file mode enabled but no file exists! (~/.cbe_dir)"
	fi
}

function CBE.Loader.PrintMessageNewLine()
{
	if [ "$CBE_CORE_SETTING_BOOL_QUIETMODE" != "true" ]; then
		echo "$1"
	fi
}

function CBE.Loader.PrintMessage()
{
	if [ "$CBE_CORE_SETTING_BOOL_QUIETMODE" != "true" ]; then
		echo -n "$1"
	fi
}

##
# Modules call this upon loading to report the status of the load. Generally ends up being
# "Ok!".
##
function CBE.Loader.PrintLoadedMessage()
{
	CBE.Loader.PrintMessageNewLine "$1"
}

function CBE.Loader.SetOptions()
{
	CBE_CORE_SETTING_BOOL_QUIETMODE="$1"
	CBE_CORE_SETTING_BOOL_FLATFILE="$2"
}

function CBE.Loader.SetUUID()
{
	CBE_UUID="$(od -vAn -N4 -tu4 < /dev/urandom)"
	CBE_UUID="${CBE_UUID##*( )}"
}

##
# Clean up references to functions and vars the user should not have access to.
##
function CBE.Loader.CleanUp()
{
	unset -f CBE.Loader.ShowIntro
	unset -f CBE.Loader.LoadModules
	unset -f CBE.Loader.PrintMessageNewLine
	unset -f CBE.Loader.PrintMessage
	unset -f CBE.Loader.LoadFlatFile
	unset -f CBE.Loader.SetOptions
	unset -f CBE.Loader.LoadSystemModules
	unset -f CBE.Loader.LoadGlobalModules
	unset -f CBE.Loader.LoadUserModules
	unset -f CBE.Loader.LoadModule
	unset -f CBE.Loader.LoadSubModule
	unset -f CBE.Loader.PrintLoadedMessage
	unset -f CBE.Loader.SetUUID

	unset CBE_CORE_TMP_LAST_DIR	
	unset CBE_CORE_SETTING_BOOL_QUIETMODE
	unset CBE_CORE_SETTING_BOOL_FLATFILE
	
	unset -f CBE.Loader.CleanUp
}

## FUNCTION CALLS

CBE.Loader.SetOptions "$1" "$2"
CBE.Loader.SetUUID
CBE.Loader.ShowIntro
CBE.Loader.LoadModules
CBE.Loader.CleanUp

## END FUNCTION CALLS

#!/bin/bash

## USER SET
CBE_CORE_INSTALL_PATH="/path/to/CBE"

CBE_CORE_GLOBAL_MODULES_PATH="$CBE_CORE_INSTALL_PATH"/modules
CBE_CORE_SYSTEM_MODULES_PATH="$CBE_CORE_INSTALL_PATH"/core
CBE_CORE_USER_MODULES_PATH="$HOME"/.cbe_modules

declare -A CBE_CORE_MODULE_UUID_TABLE

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
	
	cd "$CBE_CORE_SYSTEM_MODULES_PATH"
	
	. "api.cbe"
	. "system.cbe"
	. "help.cbe"
	
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
			
			## Generate UUID.
			CBE.API.Math.GenerateUUID
				
				## Add entry to the module UUID table. Filename as the key and the returned uuid as the value.
			CBE_CORE_MODULE_UUID_TABLE=( ["$f"]="$CBE_API_FUNCTION_RESULT")
				
			cd "$CBE_CORE_GLOBAL_MODULES_PATH"
			
			. "$f"
				
			"${CBE_CORE_MODULE_UUID_TABLE["$f"]}".Load
			"${CBE_CORE_MODULE_UUID_TABLE["$f"]}".CleanUp
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
				
				## Generate UUID.
				CBE.API.Math.GenerateUUID
				
				## Add entry to the module UUID table. Filename as the key and the returned uuid as the value.
				CBE_CORE_MODULE_UUID_TABLE=( ["$f"]="$CBE_API_FUNCTION_RESULT")
				
				cd "$CBE_CORE_USER_MODULES_PATH"
				
				. "$f"
				
				"${CBE_CORE_MODULE_UUID_TABLE["$f"]}".Load
				"${CBE_CORE_MODULE_UUID_TABLE["$f"]}".CleanUp
				
			fi
		done
	else
	
		CBE.Loader.PrintMessageNewLine "#   - WARN: No user module folder found. Skipping..."
	
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
	CBE.Loader.PrintMessageNewLine "$@"
}

function CBE.Loader.SetOptions()
{
	CBE_CORE_SETTING_BOOL_QUIETMODE="$1"
	CBE_CORE_SETTING_BOOL_FLATFILE="$2"
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
	unset -f CBE.Loader.PrintLoadedMessage

	unset CBE_CORE_TMP_LAST_DIR	
	unset CBE_CORE_SETTING_BOOL_QUIETMODE
	unset CBE_CORE_SETTING_BOOL_FLATFILE
	
	unset -f CBE.Loader.CleanUp
}

## FUNCTION CALLS

CBE.Loader.SetOptions "$1" "$2"
CBE.Loader.ShowIntro
CBE.Loader.LoadModules
CBE.Loader.CleanUp

## END FUNCTION CALLS

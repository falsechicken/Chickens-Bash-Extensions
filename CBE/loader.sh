#!/bin/bash

## USER SET
CBE_CORE_INSTALL_PATH="/path/to/CBE"


CBE_CORE_GLOBAL_MODULES_PATH="$CBE_CORE_INSTALL_PATH"/modules
CBE_CORE_SYSTEM_MODULES_PATH="$CBE_CORE_INSTALL_PATH"/core
CBE_CORE_USER_MODULES_PATH="$HOME"/.cbe_modules

CBE_CORE_BOOL_QUITEMODE=""
CBE_CORE_BOOL_FLATFILE=""

CBE_CORE_VERSION="v0.0.1"

function CBE.Loader.ShowIntro()
{
	CBE.Loader.PrintMessageNewLine "##"
	CBE.Loader.PrintMessageNewLine "# == Chicken's Bash Extensions =="
	CBE.Loader.PrintMessageNewLine "#	- Version $CBE_CORE_VERSION -"
	CBE.Loader.PrintMessageNewLine "#"
	CBE.Loader.PrintMessageNewLine "# - All extension commands are prefixed with '@'. -"
	CBE.Loader.PrintMessageNewLine "#"
}

## Initialize Modules
function CBE.Loader.LoadModules()
{
	## Check if we are using flatfile mode
	if [ "$CBE_CORE_BOOL_FLATFILE" == "true" ]; then
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
	
	for f in *.cbe; do 
		if [ "$f" == "*.cbe" ]; then
			CBE.Loader.PrintMessageNewLine "# ERROR: No system modules found!"
			return 0
		else
			. "$f"
		fi
	done
	
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
			CBE.Loader.PrintMessage "#   - Global Module: ${f%.*}"
			. "$f"
			CBE.Loader.PrintMessageNewLine " ... Ok!"
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
				CBE.Loader.PrintMessage "#   - User Module: ${f%.*}"
				. "$f"
				CBE.Loader.PrintMessageNewLine " ... Ok!"
			fi
		done
	else
	
		CBE.Loader.PrintMessageNewLine "#   - WARN: No user module folder found. Skipping..."
	
	fi

}

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
	if [ "$CBE_CORE_BOOL_QUITEMODE" != "true" ]; then
		echo "$1"
	fi
}

function CBE.Loader.PrintMessage()
{
	if [ "$CBE_CORE_BOOL_QUITEMODE" != "true" ]; then
		echo -n "$1"
	fi
}

function CBE.Loader.SetOptions()
{
	CBE_CORE_BOOL_QUITEMODE="$1"
	CBE_CORE_BOOL_FLATFILE="$2"
}

#
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

	unset CBE_CORE_TMP_LAST_DIR	
	unset CBE_CORE_BOOL_QUITEMODE
	unset CBE_CORE_BOOL_FLATFILE
}

## FUNCTION CALLS

CBE.Loader.SetOptions "$1" "$2"
CBE.Loader.ShowIntro
CBE.Loader.LoadModules
CBE.Loader.CleanUp

## END FUNCTION CALLS

unset -f CBE.Loader.CleanUp

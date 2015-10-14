= Chicken's Bash Extensions =

"Plug-ins" for Bash.

== TO USE ==

Insert ". /path/to/cbe/loader.sh false false" into the bottom of your .bashrc file and edit the CBE_CORE_INSTALL_PATH in the loader.sh script to your CBE folder 

OR

Insert ". /path/to/cbe/loader.sh false true" and create the file ~/.cbe_dir and add the CBE install path to the first line.


Loader usage: loader.sh <quiet mode> <flatfile mode>

Quiet Mode: Disable startup loading messages.

FlatFile Mode: Pull the CBE_CORE_INSTALL_PATH from ~/.cbe_dir instead of the hard coded script variable.

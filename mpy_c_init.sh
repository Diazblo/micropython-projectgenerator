#!/bin/bash

MICROPYTHON_GIT='https://github.com/Diazblo/micropython.git'
ESPIDF_GIT='https://github.com/espressif/esp-idf.git'
VSCODE_SETTINGS='./.vscode/settings.json'
INIT_SCRIPT_PATH='${workspaceFolder}/init_terminal.sh'
VSCODE_SETTINGS_STRING="\"terminal.integrated.shellArgs.linux\": [\"--init-file\", \"${INIT_SCRIPT_PATH}\"]"

# echo $VSCODE_SETTINGS_STRING
# exit 1


# <<comment

# Making modules directory
mkdir -p modules native_modules

if [ -d "./Makefile" ]; then
    echo Makefile already exists.
else
    read -p "Create Makefile? " -n 1 -r
    echo    # (optional) move to a new line
    if [[  $REPLY =~ ^[Yy]$ ]]
    then
        echo Creating sample Makefile config
        cat <<EOF >./Makefile
# Makefile for building Native modules

# Source files (.c or .py)
SRC = \$(MOD_DIR)/factorial/*.c

# Name of module
MOD = factorial


# Architecture to build for (x86, x64, armv7m, xtensa, xtensawin)
ARCH = xtensawin

# Default port
PORT ?= /dev/ttyUSB0

# Location of top-level MicroPython directory
MPY_DIR = ./micropython

# Location of top-level MicroPython directory
MOD_DIR = ./native_modules

# Include to get the rules for compiling and linking the module
include \$(MPY_DIR)/py/dynruntime.mk

deploy:
	\$(MPY_DIR)/tools/pyboard.py --device \$(PORT) -f ls
	\$(MPY_DIR)/tools/pyboard.py --device \$(PORT) -f cp ./*.mpy :

run:
	\$(MPY_DIR)/tools/pyboard.py --device \$(PORT)
EOF

        cat <<EOF >./modules/micropython.cmake
# This top-level micropython.cmake is responsible for listing
# the individual modules we want to include.
# Paths are absolute, and \${CMAKE_CURRENT_LIST_DIR} can be
# used to prefix subdirectories.

# Add the C example.
# include(\${CMAKE_CURRENT_LIST_DIR}/cexample/micropython.cmake)

# Add the CPP example.
# include(\${CMAKE_CURRENT_LIST_DIR}/cppexample/micropython.cmake)

EOF
    fi
fi

# Terminal init scripting

if test -f "$VSCODE_SETTINGS"; then
    if  grep -q "$INIT_SCRIPT_PATH" "$VSCODE_SETTINGS"; then
        echo VS Code workspace settings contains init script already.
    else
        echo "Adding init_terminal.sh to VS Code workspace settings"
        sed -i '$ s/.$//' $VSCODE_SETTINGS
        sed -i -e '$s/$/,/' $VSCODE_SETTINGS
        echo -n -e "\n\t$VSCODE_SETTINGS_STRING\n}" >> $VSCODE_SETTINGS
    fi
else
    if [ -d ".vscode" ]; then
        echo .vscode folder exists
    else
        mkdir .vscode
    fi
    echo "Creating VS Code working settings.json"
    echo -n -e "{\n\t$VSCODE_SETTINGS_STRING\n}" >> $VSCODE_SETTINGS
fi


# Micropython repo
read -p "Clone micropython repository? " -n 1 -r
    echo    # (optional) move to a new line
    if [[  $REPLY =~ ^[Yy]$ ]]
    then
        if git rev-parse --git-dir > /dev/null 2>&1; then
            : # This is a valid git repository (but the current working
            # directory may not be the top level.
            # Check the output of the git rev-parse command if you care)
            echo Current project is a git directory. Adding submodules
            git submodule add $MICROPYTHON_GIT
            git submodule update --init --recursive
        else
            : # this is not a git repository
            echo Current project is not a git directory.
            read -p "Do you want to initialize repo?" -n 1 -r
            echo    # (optional) move to a new line
            if [[  $REPLY =~ ^[Yy]$ ]]
            then
                echo initalize repo
            fi
        fi
    fi



# ESP-IDF

read -p "Install ESP-IDF in HOME/esp ? " -n 1 -r
    echo    # (optional) move to a new line
    if [[  $REPLY =~ ^[Yy]$ ]]
    then
        mkdir -p ~/esp
        cd ~/esp
        git clone --recursive $ESPIDF_GIT
        cd ~/esp/esp-idf
        ./install.sh esp32
    fi


# comment
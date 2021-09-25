#!/bin/bash

PORT='/dev/ttyUSB0'

NATIVE_MOD_DIR='../../../../native_modules/'
MOD_DIR='../../../../modules/'
ESPIDF_PATH=$HOME/esp/esp-idf


source ~/.bashrc
. ${ESPIDF_PATH}/export.sh

read -p "Compile only Modules? " -n 1 -r
echo    # (optional) move to a new line
if [[  $REPLY =~ ^[Yy]$ ]]
then
    # cd ./modules
    read -p "Buid modules and upload? " -n 1 -r
    echo    # (optional) move to a new line
    if [[  $REPLY =~ ^[Yy]$ ]]
    then
        make
        make deploy
        make run
    fi
else 
    cd ./micropython/ports/esp32/
    read -p "Build micropython with cmodules? " -n 1 -r
    echo    # (optional) move to a new line
    if [[  $REPLY =~ ^[Yy]$ ]]
    then
        # make
        make USER_C_MODULES=$MOD_DIR/micropython.cmake
        read -p "Upload micropython with cmodules and open console? " -n 1 -r
        echo    # (optional) move to a new line
        if [[  $REPLY =~ ^[Yy]$ ]]
        then
            make USER_C_MODULES=$MOD_DIR/micropython.cmake BAUD=921600 deploy
            picocom $PORT -b115200
            echo "make USER_C_MODULES=$MOD_DIR/micropython.cmake BAUD=921600 deploy && picocom $PORT -b115200"
        fi
    fi
fi

# copy this in workspace settings.json
# "terminal.integrated.shellArgs.linux": ["--init-file", "${workspaceFolder}/init_terminal.sh"]

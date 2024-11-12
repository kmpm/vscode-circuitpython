#!/usr/bin/env bash

# This script clones the circuitpython repo, checks out the specified version,
# and generates stubs for the modules in the repo. It then copies the stubs
# into the stubs directory in this repo. It also generates stubs for the board
# modules in the boards directory in this repo.

VERSION=${1:-9.2.0}

(
    # Current dir should be the root of the repo
    cd $(dirname $0)/..

    if [ -d circuitpython ]; then
        echo "circuitpython directory already exists. Will not clone again."
        echo "Remove the directory if you want to clone again or change version."
        cd circuitpython
    else
        echo "Cloning circuitpython repo"
        git clone https://github.com/adafruit/circuitpython.git
        cd circuitpython
        echo "Checking out $VERSION"
        git checkout $VERSION
    fi

    
    # use the make commands instead of the git commands
    make fetch-all-submodules

    # Use a venv for these
    # Using this name so circuitpython repo already gitignores it
    if [ ! -d .venv ]; then
        echo "Creating venv"
        python3 -m venv .venv/
    else
        echo "Venv already exists. Will not create again."
    fi
    . .venv/bin/activate

    # `make stubs` in circuitpython
    pip3 install wheel  # required on debian buster for some reason
    pip3 install -r requirements-doc.txt
    make stubs
    if [ -d ../stubs ]; then
        # if stubs already exists, remove it to avoid getting out of sync with circuitpython
        rm -rf ../stubs
        rm -rf ../boards
    fi
    # copy stubs instead of moving them if we need to rerun this script
    cp -r circuitpython-stubs/ ../stubs

    cd ..

    # scripts/build_stubs.py in this repo for board stubs
    python3 ./scripts/build_stubs.py
    rm -rf stubs/board

    echo "Done! Stubs and boards are generated."
    # was crashing on `deactivate`, but guess what?! We're in parenthesis, so
    # it's a subshell. venv will go away when that subshell exits, which is,
    # wait for it.... now!
)

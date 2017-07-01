#!/bin/bash

source cf-common.sh

function main {

    local proceed=false

    printHeader
    printAwsAccountInfo
    getRunList
    printRunList
    planStacks

    confirm "Are you sure you want to apply these changes? [Y/n]" && proceed=true

    if [ "$proceed" = true ]; then
        applyStacks
    else
        newline
    fi

    printFooter

}

function printHeader {

    newline
    textColor $GREEN
    echo -n "* your changesets will be described "
    textColor $CYAN
    echo "in cyan"
    textColor $GREEN
    echo -n "* aws cli deploy results will also show "
    textColor $CYAN
    echo "in cyan"
    textColor $GREEN
    echo "* your changes WILL be applied"
    newline
    echo "------------------------------------"
    echo "---- begin cloudformation apply ----"
    echo "------------------------------------"
    newline
    textColor $NO_COLOR

}

function printFooter {

    textColor $GREEN
    echo "---------------------------------------"
    echo "---- cloudformation apply complete ----"
    echo "---------------------------------------"
    newline

    if [ "$proceed" = false ]; then
        echo "* exiting now, these changes have NOT been applied"
        newline
    fi

    textColor $NO_COLOR

}

function applyStacks {

    newline

    for i in "${RUN_LIST[@]}"
    do
        local stackName=$i
        applyStack "$stackName"
    done

}

function applyStack {

    local stackName=$1

    textColor $GREEN
    echo "deploying stack '$stackName'..."
    textColor $NO_COLOR

    deploy $stackName true

}

main
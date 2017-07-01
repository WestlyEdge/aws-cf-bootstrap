#!/bin/bash

source cf-common.sh

function main {

    printHeader
    printAwsAccountInfo
    getRunList
    printRunList
    planStacks
    printFooter

}

function printHeader {

    newline
    textColor $GREEN
    echo -n "* your changesets will be described "
    textColor $CYAN
    echo "in cyan"
    textColor $GREEN
    echo "* your changes will NOT be applied"
    echo "* you will need to run cf-apply.sh to apply these changes"
    newline
    echo "-----------------------------------"
    echo "---- begin cloudformation plan ----"
    echo "-----------------------------------"
    newline
    textColor $NO_COLOR

}

function printFooter {

    textColor $GREEN
    echo "--------------------------------------"
    echo "---- cloudformation plan complete ----"
    echo "--------------------------------------"
    newline
    echo "* run cf-apply.sh to apply these changes"
    newline
    textColor $NO_COLOR

}

main
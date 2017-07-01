#!/bin/bash

CYAN="\033[0;36m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"
RUN_LIST_FILE_PATH="../../run-list.txt"
PARAM_FILE_DIR_PATH="params/"
TEMPLATE_FILE_DIR_PATH="../../templates/"
RUN_LIST=()

function getRunList {

    local runListIndex=0;

    IFS=$'\n' read -d '' -r -a lines < $RUN_LIST_FILE_PATH

    for i in "${lines[@]}"
    do
        if [[ "$i" != "#"* ]]; then
            RUN_LIST[runListIndex]=$i
            ((runListIndex=runListIndex+1))
        fi
    done

}

function printRunList {

    local index=1;

    echo "your run list..."
    newline

    for i in "${RUN_LIST[@]}"
    do
        echo "$index) $i"
        ((index=index+1))
    done

    newline

}

function textColor {
    local color=$1
    printf "${color}"
}

function newline {
    printf "\n"
}

function printAwsAccountInfo {

    echo "you are currently working with this aws account..."
    newline
    aws iam list-account-aliases
    newline

}

function execute {

    local command=$1
    local printCommand=$2
    local getResponse=$3
    local showWait=$4

    response=""

    if [ "$printCommand" = true ]; then
        newline
        echo "+ "$command
    fi

    if [ "$showWait" = true ]; then
        newline
        echo "waiting..."
    fi

    if [ "$getResponse" = true ]; then
        response=$($command) || response="error on execute"
    else
        textColor $CYAN
        newline
        $command
        textColor $NO_COLOR
    fi

}

function getParams {

    local stackName=$1
    local paramIndex=0;
    local paramFilePath="$PARAM_FILE_DIR_PATH$stackName.txt"
    params=""

    IFS=$'\n' read -d '' -r -a lines < $paramFilePath

    for i in "${lines[@]}"
    do
        if [[ "$i" != "#"* ]]; then
            params="$params$i "
            ((paramIndex=paramIndex+1))
        fi
    done

}

function deploy {

    local stackName=$1
    local executeChangeSet=$2

    getParams $stackName

    local command="aws cloudformation deploy --template-file $TEMPLATE_FILE_DIR_PATH$stackName.yaml --stack-name $stackName --parameter-overrides $params"

    if [ "$executeChangeSet" = true ]; then
        deployExecute "$command"
    else
        deployNoExecute "$command"
    fi

    newline

}

function deployNoExecute {

    local command=$1

    command="$command --no-execute-changeset"

    # execute the deploy command to return a response
    execute "$command" true true true

    # do changes exist for this stack?
    if [[ $response == *"error on execute"* ]]; then

        textColor $CYAN
        newline
        echo "no need to deploy stack '$stackName', no changes were found"
        textColor $NO_COLOR

    else

        # split the response string to get the describe-change-set url
        command=${response##*changes:}

        # execute the describe-change-set command to retrieve the changeset info
        execute "$command" true false true

    fi

}

function deployExecute {

    local command=$1

    # execute the deploy command to return a response
    execute "$command" true false true

    # split the response string to get the describe-change-set url
    #command="${response##*changes:}"

    # execute the describe-change-set command to retrieve the changeset info
    #execute "$command" true false true

}

function confirm {

    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac

}

function planStacks {

    for i in "${RUN_LIST[@]}"
    do
        local stackName=$i
        planStack "$stackName"
    done

}

function planStack {

    local stackName=$1

    textColor $GREEN
    echo "creating changeset for stack '$stackName'..."
    textColor $NO_COLOR

    deploy $stackName false

}
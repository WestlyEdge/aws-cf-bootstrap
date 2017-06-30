#!/bin/bash

function main {
    highlightEcho "\n* your changesets will be described"
    beginImportantText; printf " in cyan\n"; endImportantText
    highlightEcho "* your changes will NOT be applied\n"
    highlightEcho "* you will need to run cf-apply.sh to apply these changes\n\n"
    highlightEcho "-----------------------------------\n"
    highlightEcho "---- begin cloudformation plan ----\n"
    highlightEcho "-----------------------------------\n\n"

    highlightEcho "you are currently working with this aws account...\n\n"

    aws iam list-account-aliases

    getRunList
    planStacks

    highlightEcho "\n--------------------------------------\n"
    highlightEcho "---- cloudformation plan complete ----\n"
    highlightEcho "--------------------------------------\n\n"
    highlightEcho "* run cf-apply.sh to apply these changes\n\n"
}

function getRunList {
    local runListIndex=0;

    IFS=$'\n' read -d '' -r -a lines < ../../run-list.txt

    for i in "${lines[@]}"
    do
        if [[ "$i" != "#"* ]]; then
            runList[runListIndex]=$i
            runListIndex=$((runListIndex+1))
        fi
    done
}

function planStacks {

    # plan for all stacks
    for i in "${runList[@]}"
    do
        local stackName=$i
        planStack "$stackName"
    done
}

function planStack {
    local stackName=$1
    local changeSetName="cs-$(date +%s)$RANDOM"

    highlightEcho "\ncreating changeset for stack '$stackName'...\n\n"

    getChangeSetType
    createChangeSet
    describeChangeSet

    if [[ "$changeSetType" = "$CREATE" ]]; then
        deleteStack
    fi
}

function getChangeSetType {
    UPDATE="UPDATE"
    CREATE="CREATE"

    execute "aws cloudformation describe-stacks --stack-name $stackName" true true

    if [[ $response == *"error on execute"* ]]; then
        stackExists=false
        changeSetType="$CREATE"
        printf "\nstack '$stackName' does NOT exist yet, it will be created\n\n"
    else
        stackExists=true
        changeSetType="$UPDATE"
        printf "stack '$stackName' already exists, it will be updated\n\n"
    fi

}

function createChangeSet {
    execute "aws cloudformation create-change-set --change-set-type $changeSetType --template-body file://../../templates/$stackName.yaml --stack-name $stackName --parameters file://params/$stackName.json --change-set-name $changeSetName" true false
}

function describeChangeSet {
    local CREATE_IN_PROGRESS="CREATE_IN_PROGRESS"

    printf "\n"
    execute "aws cloudformation describe-change-set --stack-name $stackName --change-set-name $changeSetName" true true

    while [[ $response == *"$CREATE_IN_PROGRESS"* ]]; do
        wait
        execute "aws cloudformation describe-change-set --stack-name $stackName --change-set-name $changeSetName" false true
    done

    waitComplete
    beginImportantText

    execute "aws cloudformation describe-change-set --stack-name $stackName --change-set-name $changeSetName" false false

    endImportantText
}

function deleteStack {
    printf "\n"
    execute "aws cloudformation delete-stack --stack-name $stackName" true
    printf "cleanup complete... temporary new stack '%s' has been deleted\n" $stackName
}

function execute {
    local command=$1
    local printCommand=$2
    local getResponse=$3
    local showWait=$4

    if [ "$printCommand" = true ]; then
        printf "+ $command\n\n"
    fi

    if [ "$showWait" = true ]; then
        printf "waiting...\n\n"
    fi

    if [ "$getResponse" = true ]; then
        response=$($command) || response="error on execute"
    else
        $command
    fi
}

function highlightEcho {
    local text=$1
    local green='\033[0;32m'
    local noColor='\033[0m'

    printf "${green}$text${noColor}"
}

function beginImportantText {
    local importantColor='\033[0;36m'
    local noColor='\033[0m'
    printf "${importantColor}"
}

function endImportantText {
    local noColor='\033[0m'
    printf "${noColor}"
}

function wait {
    waiting=true
    printf "waiting..."
}

function waitComplete {
    if [ "$waiting" = true ]; then
        printf "\n\n"
        waiting=false
    fi
}

main


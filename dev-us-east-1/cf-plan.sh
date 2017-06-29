#!/bin/bash

function highlightEcho {
    local text=$1
    local green='\033[0;32m'
    local noColor='\033[0m'

    printf "${green}$text${noColor}\n"
}

function execute {
    local command=$1
    printf "+ $command\n\n"
    $command
}

function planStack {
    local stackName=$1
    local changeSetName="cs-$(date +%s)$RANDOM"

    highlightEcho "\ncreating changeset for stack '$stackName'...\n"

    execute "aws cloudformation create-change-set --template-body file://../templates/$stackName.yaml --stack-name $stackName --parameters file://params/$stackName.json --change-set-name $changeSetName"

    highlightEcho "\ndescribing changeset for stack '$stackName'...\n"

    execute "aws cloudformation describe-change-set --stack-name $stackName --change-set-name $changeSetName"
}

highlightEcho "-----------------------------------"
highlightEcho "---- begin cloudformation plan ----"
highlightEcho "-----------------------------------\n"

highlightEcho "plan is being applied to this aws account...\n"

aws iam list-account-aliases

# plan for all stacks
planStack base-network-infra
planStack nat

highlightEcho "\n--------------------------------------"
highlightEcho "---- cloudformation plan complete ----"
highlightEcho "--------------------------------------\n"



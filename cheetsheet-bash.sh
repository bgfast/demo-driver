#!/bin/bash

# to do list
# change the font color to yellow for all verbose debug statements
# Change the font to green for all information commands
# specify the log analytics workspace name so it is consistent

echo "<H1>Visual Studio Code</H1>"
echo "how to run the file. From the prompt type: $. ./cheetsheet-bash.sh"
echo "The . will 'source' the file. This means that the variables will be evaluated into the shell terminal. " 
echo "To do: find a url reference to explain"
echo " "


echo "<H1> Visual Studio Code</H1>"
echo "  1) Setup F8 to run current line or selected text"
echo "  2) Use ctrl+\` to switch cursor to terminal (That's the backtic key)"


echo ""
echo "############################################"
echo "## "
echo "## Color fun"
echo "## "


: << 'COMMENT'
Ideas for log levels
0 - Emergency (emerg)
1 - Alerts (alert)
2 - Critical (crit)
3 - Errors (err)
4 - Warnings (warn)
5 - Notification (notice)
6 - Information (info)
7 - Debug (debug) 
8 - Trace (trace) 
COMMENT

LOG_INFO=6
LOG_DEBUG=7
LOG_TRACE=8
LOG_LEVEL=$LOG_DEBUG
LOG_LEVEL=$LOG_INFO

: << 'COMMENT'
echo -e "\e[1;31m Bold Red \e[0;31m"
echo -e "\e[31m Red "
echo "$(tput setaf 0) 0 Gray"
echo "$(tput setaf 1) 1 Red"
echo "$(tput setaf 2) 2 Green"
echo "$(tput setaf 3) 3 Yellow"
echo "$(tput setaf 4) 4 Blue"
echo "$(tput setaf 5) 5 Purple"
echo "$(tput setaf 6) 6 Light Blue"
echo "$(tput setaf 7) 7 White"
return 43
COMMENT


: << 'COMMENT'
This is the first line of a multiline comment
This is the second line
echo "Value of X is ${X}"
X=$((X-1))
COMMENT

# Next, install or update the Azure Container Apps extension for the CLI.
#az extension add --name containerapp --upgrade

# Register the Microsoft.App and Microsoft.OperationalInsights namespaces if you 
# haven't already registered them in your Azure subscription.
#az provider register --namespace Microsoft.App
#az provider register --namespace Microsoft.OperationalInsights

#setup environment variables
UNIQUE_ID="4"
ACR_NAME="crbrent$UNIQUE_ID"

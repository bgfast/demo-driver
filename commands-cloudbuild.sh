#!/bin/bash

# setup variables
LOCATION="westus"
IMAGE_NAME="album-api-go"
CONTAINER_APP_NAME="album-api"
SH_DRIVER_ROOT=$(pwd)

SH_USE_REDIS=false
SH_SMOKE_TEST_TEXT=""
# Put the path for the rest endpoint
SH_SMOKE_TEST_ENDPOINT="orthopedicSurgeries"

UNIQUE_ID="7"
# Define a container registry name unique to you.
ACR_NAME="$USERNAME$UNIQUE_ID"
CUSERNAME=$ACR_NAME

RESOURCE_GROUP="rg-$USERNAME-$UNIQUE_ID"
ENVIRONMENT="env-album-containerapps"

LOG_INFO=6
LOG_DEBUG=7
LOG_TRACE=8
LOG_LEVEL=$LOG_DEBUG
LOG_LEVEL=$LOG_INFO

# to do
### 1 
# fix the redis var issue seen on Randy's machine
# Create an OpenAI sample which shows generating a bash script. Hard code known examples of questions that return solid code
# Create a Python example round trip for ocr, and classification, form recognizer
### 2
# display the subscription name of the current subscription 
# Make the RG unique for each sample
# cleanup the rg is the api call succeeds 
# what to do if you want to use a branch rather than the main branch
# use git commands to fork and branch the repo
# add version info to this script
# split the zip section into a function and maybe a separate script. options are: zipurl, target directory for root, delete and overwrite directory contents, 
# confirm the subscription name is correct
# check for installed extensions in VS Code
# code a better solution for the projects directory
# create the redis service
# Get the hostname and creds from the redis service
# to do list
# change the font color to yellow for all verbose debug statements
# Change the font to green for all information commands
# specify the log analytics workspace name so it is consistent
# set the log analytics workspace name to a variable
# output the current settings: rgname, root directory, etc. ask if they want to change them
# cd back to the SH_DRIVER_ROOT directory on every fail condition
# Make the menu choices also available as command line arguments and have a silent mode
# Create a driver of the driver script which will smoke test all the samples
# for the projects directory, make all new sample directories be siblings of the demo-driver directory
# Cleanup all the command line output
# Cleanup the menu choices
### 3
# read menu options and choice variable settings from a json file
##DONE## 
# - use the loged in users name $USERNAME
# only download and unzip the file if the directory doesn't exist or if force flag is used

# Make sure the script is being sourced, not executed.
if [ "$0" == "$BASH_SOURCE" ]; then
    echo "This script must be sourced, not executed."
    echo "Follow this format [dot space dot forwardslash filename] i.e. $ . ./filename.sh"
    exit 1
fi


# to do: make this projects directory code work on any computer
# to do: create the projects directory if it doesn't exist and create the continer-apps directory
cd ..
SH_PROJECTS_ROOT=$(pwd)
cd $SH_DRIVER_ROOT
# Create the directory if it doesn't exist.

SH_WAITING_FOR_MENU_CHOICE=true
SH_PROJECT_ROOT="containerapps-api-staticfile-javascript"

pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}

one(){
	echo "one() called"
    ZIPURL="https://github.com/Azure-Samples/containerapps-albumapi-csharp/archive/refs/heads/main.zip"
    SH_WAITING_FOR_MENU_CHOICE=false
    IMAGE_NAME="album-api-csharp"
    SH_SMOKE_TEST_ENDPOINT="orthopedicSurgeries"
    SH_SMOKE_TEST_TEXT=""
    pause
}
 
# do something in two()
two(){
	echo "Run the redis cache sample from bgfast"
    ZIPURL="https://github.com/bgfast/containerapps-api-staticfile-javascript/archive/refs/heads/Redis.zip"
    SH_PROJECT_ROOT="containerapps-api-staticfile-javascript"
    SH_WAITING_FOR_MENU_CHOICE=false
    IMAGE_NAME="album-api-nodejs-redis"
    SH_USE_REDIS=true
    SH_SMOKE_TEST_ENDPOINT="orthopedicSurgeriesFromRedis"
    SH_SMOKE_TEST_TEXT="Knee"
    pause
}
 
# This is the classic Python Album API sample from bgfast
three(){
	echo "Run the python cache sample from bgfast"
    ZIPURL="https://github.com/bgfast/api-python/archive/refs/heads/master.zip"
    SH_PROJECT_ROOT="api-python"
    SH_WAITING_FOR_MENU_CHOICE=false
    IMAGE_NAME="album-api-python"
    SH_SMOKE_TEST_ENDPOINT="albums"
    SH_SMOKE_TEST_TEXT="Python"
    SH_ZIP_INSIDE_ROOT="api-python-master"
    pause
}

# do something in four()
four(){
	echo "Run the python Azure Open AI sample from bgfast"
    ZIPURL="https://github.com/bgfast/containerapps-api-staticfile-javascript/archive/refs/heads/Redis.zip"
    SH_WAITING_FOR_MENU_CHOICE=false
    SH_PROJECT_ROOT="api-tbd-python"
    IMAGE_NAME="album-api-nodejs-redis"
    SH_SMOKE_TEST_ENDPOINT="orthopedicSurgeriesFromRedis"
    SH_SMOKE_TEST_TEXT="Knee"
    pause
}

# function to display menus
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Deploy PG Album API - C#"
    echo "     Deploy GitHub PG sample: containerapps-albumapi-csharp"
	echo "2. Reset Terminal"
	echo "3. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options(){
    items=("PG-Album API (C#)" "BGFAST-HLS-Redis (nodejs)" "BGFAST-Album Python API" "Item 4" "Show Full Menu" "Quit")

    while $SH_WAITING_FOR_MENU_CHOICE; do
        select item in "${items[@]}" 
        do
            case $REPLY in
                1) echo "Selected item #$REPLY"; one; break;;
                2) echo "Selected item #$REPLY "; two; break;;
                3) echo "Selected item #$REPLY "; three; break;;
                4) return 43; break;;
                $((${#items[@]}+1))) echo "We're done!"; break 2;;
                *) echo "Ooops - unknown choice $REPLY"; break;
            esac
        done
    done
	#local choice
	#read -p "Enter choice [ 1 - 3] " choice
	#case $choice in
	#	1) one ;;
	#	2) two ;;
	#	3) exit 0;;
	#	*) echo -e "${RED}Error...${STD}" && sleep 2
	#esac
}
 
# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
#trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
read_options

########################################################
##
## Start all the zip work
##
##

## if the directory does not exist, create it
#echo "$SH_PROJECTS_ROOT/$SH_PROJECT_ROOT" 
if [ ! -d "$SH_PROJECTS_ROOT/$SH_PROJECT_ROOT" ]; then
    cd "$SH_PROJECTS_ROOT"
    #echo "Zip URL=$ZIPURL"
    curl -SL $ZIPURL > file.zip
    unzip -d "$TMP" file.zip 
    #echo "mv $TMP/$SH_ZIP_INSIDE_ROOT $SH_PROJECTS_ROOT/$SH_PROJECT_ROOT" 
    mv "$TMP/$SH_ZIP_INSIDE_ROOT" "$SH_PROJECTS_ROOT/$SH_PROJECT_ROOT" 
    rm file.zip
else
    echo "Directory already exists: $SH_PROJECTS_ROOT/$SH_PROJECT_ROOT skipping unzip"
fi


if [ ! -d "$SH_PROJECTS_ROOT/$SH_PROJECT_ROOT/src" ]; then
    echo "unzip failed to extract in the correct directory: $SH_PROJECTS_ROOT/$SH_PROJECT_ROOT"
    return 42
else
    echo "Successfully unziped file in: $SH_PROJECTS_ROOT/$SH_PROJECT_ROOT"
fi

##
## Done with all the zip work
##
##
########################################################


#. ./commands.secure.sh
# to do create the secrets file and import it here

# Quickstart: Deploy your code to Azure Container Apps - Cloud build
# https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Ccsharp&pivots=acr-remote


#az login
#az account set --subscription $SUBSCRIPTIONID
#az upgrade


# Next, install or update the Azure Container Apps extension for the CLI.
#az extension add --name containerapp --upgrade

# Register the Microsoft.App and Microsoft.OperationalInsights namespaces if you 
# haven't already registered them in your Azure subscription.
#az provider register --namespace Microsoft.App
#az provider register --namespace Microsoft.OperationalInsights


# https://github.com/Azure-Samples/azure-cli-samples/blob/master/container-registry/create-registry/create-registry-service-principal-assign-role.sh
# Get the details of the registry 
# https://stackoverflow.com/questions/43373176/store-json-directly-in-bash-script-with-variables
# asset_ID=$( curl '...' | jq --raw-output '.AssetID' )
# https://stackoverflow.com/questions/47018863/parsing-and-storing-the-json-output-of-a-curl-command-in-bash
#declare -a CIE_ACR

##############################################
##
## Start section for Resource Group 
##

if (($LOG_LEVEL>=$LOG_DEBUG))
then
    echo "Running command to check for resource group:"
    echo "az group exists -n $RESOURCE_GROUP"
    #if ((a > 5)); then echo "a is more than 5"; fi

    if (($LOG_LEVEL>=$LOG_TRACE))
    then
        az group exists -n $RESOURCE_GROUP
    fi
fi
if (($LOG_LEVEL>=$LOG_INFO))
then
    echo "Checking for resource group:$RESOURCE_GROUP"
fi
SH_RG=$(az group exists -n $RESOURCE_GROUP)
if [[ $SH_RG = *true* ]]
then
    echo "The resource group already exists"
else
    echo "Create resource group"
    az group create -l $LOCATION -n $RESOURCE_GROUP
    SH_RGC=$(az group create -l $LOCATION -n $RESOURCE_GROUP)
    if [[ $SH_RGC = *Succeeded* ]]
    then
        echo "Successfully created the resource group $RESOURCE_GROUP"
    else
        echo "Failed to create the resource group $RESOURCE_GROUP"
        return 42
    fi
fi

##
## End section for Resource Group 
##
##############################################


##############################################
##
## Start section for Azure Container Registry
##

#retVal=42
#return ${retVal} 2>/dev/null || exit "${retVal}"

#CIE_ACR = $(('az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP'))
# https://learn.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az-group-exists
#if (($LOG_LEVEL>=$LOG_DEBUG))
#then
#    echo "Running command:"
#    echo "az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP"
#    az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP
#fi
if (($LOG_LEVEL>=$LOG_DEBUG))
then
    echo "Running command to check for azure container registry:"
    echo "az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP"
    az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP
fi

echo "$(tput setaf 2)Checking for azure container registry $ACR_NAME $(tput setaf 7) "
CIE_ACR=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP)
#echo ${CIE_ACR} # This doesn't render correctly- not sure why
if [[ $CIE_ACR = *creationDate* ]]
then
    echo "The Azure Container Registry already exists"
    if (($LOG_LEVEL>=$LOG_DEBUG))
    then
        echo "Running command to get the container registry credentials"
        echo "az acr credential show -n $ACR_NAME --query passwords[0].value"
    fi
    CPASSWORD=$(az acr credential show -n $ACR_NAME --query passwords[0].value)
    # Strip the quotes off the password
    eval CPASSWORD=$CPASSWORD
else
    echo "$(tput setaf 2) Create the Azure Container Registry"

    # https://learn.microsoft.com/en-us/powershell/module/az.containerregistry/get-azcontainerregistry?view=azps-9.2.0
    # create the container registry
    SH_ACRC=$(az acr create \
      --resource-group $RESOURCE_GROUP \
      --name $ACR_NAME \
      --sku Basic \
      --admin-enabled true 2>&1) 
    
    if [[ $SH_ACRC = *ERROR* ]]
    then
        echo "$(tput setaf 1)ERROR creating the Azure Container Registry"
        echo "$SH_ACRC"
        return 42
    fi
    CPASSWORD=$(az acr credential show -n $ACR_NAME --query passwords[0].value)
    
    # Strip the quotes off the password
    eval CPASSWORD=$CPASSWORD

fi


##
## End section for Azure Container Registry
##
##############################################


##############################################
##
## Start section to perform a cloud build of the image and store it in the registry
##
# Build the container in Azure
# To do - how to know when the container needs to be rebuilt. Perhaps a flag on the script?
if (($LOG_LEVEL>=$LOG_DEBUG))
then
    echo "Running command to perform a cloud build:"
    echo "  az acr build --registry $ACR_NAME --image $IMAGE_NAME --only-show-errors ."
fi
## to do - identify why this build failed on a clean run and built successfully later with no code changes. was it a timing issue? 
## perhaps try this command 3 times before failing
## if it fails once, then run it again with the --debug flag

# the cloud build requires the current working directory to be src. This is so the Docker build can find the Dockerfile
cd "$SH_PROJECTS_ROOT\\$SH_PROJECT_ROOT\src"
echo "$(tput setaf 2)Performing cloud build of image:$IMAGE_NAME in registry:$ACR_NAME $(tput setaf 7) "
SH_ACR_BUILD=$(az acr build --registry $ACR_NAME --image $IMAGE_NAME --only-show-errors .)
$(az acr build --registry $ACR_NAME --image $IMAGE_NAME --no-logs --only-show-errors .)
if [[ $SH_ACR_BUILD = *successful* ]]
then
    echo "$(tput setaf 2)Finished successful build $(tput setaf 7) "
else
    ## to do check the result for errors and output the error messages
    echo "If this is a python build, it often fails on the pip install command. Try adding the progress bar to the Dockerfile"
    echo "RUN pip install --no-cache-dir --progress-bar off --upgrade -r /code/requirements.txt"
    echo "Build failed: $SH_ACR_BUILD"
    return 42
fi
cd "$SH_DRIVER_ROOT"

###############
# Strange output from the build command
#Performing cloud build of image:album-api-python in registry:username5
#bash: $'{\r': command not found
#Press [Enter] key to continue...
#WARNING: Packing source code into tar to upload...
#WARNING: Uploading archived source code from 'C:\Users\username\AppData\Local\Temp\build_archive_2fc0eb31d716462cbb0cb4e58e68e453.tar.gz'...
#WARNING: Sending context (2.940 KiB) to registry: username5...
#WARNING: Queued a build with ID: cfc
#WARNING: Waiting for an agent...
#bash: 2023/01/29: No such file or directory
#Press [Enter] key to continue...
#
#############

##
## End section to perform a cloud build of the image and store it in the registry
##
##############################################

## Debug/test exit 
#return 42

##############################################
##
## Start Container App Environment create
##

# https://learn.microsoft.com/en-us/cli/azure/containerapp/env?view=azure-cli-latest
if (($LOG_LEVEL>=$LOG_DEBUG))
then
    az containerapp env show -n $ENVIRONMENT -g $RESOURCE_GROUP
fi
CONTAINER_APP_ENV=$(az containerapp env show -n $ENVIRONMENT -g $RESOURCE_GROUP)
echo ${CONTAINER_APP_ENV}
if [[ $CONTAINER_APP_ENV = *$ENVIRONMENT* ]]
then
    echo "The Azure Container APP Environment already exists"
else
    echo "Create the Azure Container APP Environment"

    # Create the container app environment
    az containerapp env create \
      --name $ENVIRONMENT \
      --resource-group $RESOURCE_GROUP \
      --location "$LOCATION"
fi
##
## End Container App Environment create
##
##############################################



##############################################
##
## Start Redis create 
##
#az redis list-keys [--ids]
#                   [--name]
#                   [--resource-group]
#                   [--subscription]

##
## End Redis create
##
##############################################



##############################################
##
## Start Container App create 
##

## Check if the container app has already been created. If not, then create it. If yes, then update it
if (($LOG_LEVEL>=$LOG_DEBUG))
then
    az containerapp show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP
fi
CONTAINER_APP=$(az containerapp show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP)
if [[ $CONTAINER_APP = *$CONTAINER_APP_NAME* ]]
then
    echo "The Azure Container APP already exists. Updating the Container APP..."
    # Create the container app and deploy the image
    if [ "$SH_USE_REDIS" = "true" ]; then
      THERESULT=$(az containerapp update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --image $ACR_NAME.azurecr.io/$IMAGE_NAME --set-env-vars rediscachekey=secretref:rediscachekey rediscachehostname=secretref:rediscachehostname)
    else
      THERESULT=$(az containerapp update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --image $ACR_NAME.azurecr.io/$IMAGE_NAME)
    fi
    if [[ $THERESULT = *Succeeded* ]]
    then
        echo "Successfully updated container app"
    else
        echo "Failed to update container app"
        return 42
    fi
else
    echo "Create the Azure Container APP"

    # to do - there's a bug on one of the following lines. bash throws and end of file error

    # Create the container app and deploy the image
    echo "Running command"
    echo "az containerapp create --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT --image $ACR_NAME.azurecr.io/$IMAGE_NAME --target-port 3500 --ingress 'external' --registry-server $ACR_NAME.azurecr.io --query properties.configuration.ingress.fqdn --registry-password $CPASSWORD --registry-username $CUSERNAME"
    if [ "$SH_USE_REDIS" = "true" ]; then
      THERESULT=$(az containerapp create -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --environment $ENVIRONMENT --image $ACR_NAME.azurecr.io/$IMAGE_NAME --set-env-vars rediscachekey=secretref:rediscachekey rediscachehostname=secretref:rediscachehostname --target-port 3500 --ingress 'external' --registry-server $ACR_NAME.azurecr.io --query properties.configuration.ingress.fqdn --registry-password $CPASSWORD --registry-username $CUSERNAME)
    else
      THERESULT=$(az containerapp create -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --environment $ENVIRONMENT --image $ACR_NAME.azurecr.io/$IMAGE_NAME --target-port 3500 --ingress 'external' --registry-server $ACR_NAME.azurecr.io --query properties.configuration.ingress.fqdn --registry-password $CPASSWORD --registry-username $CUSERNAME)
    fi
    # to do - catch the result of the command and return an error if it fails
    #echo "To do: Act on the result "
    echo "$THERESULT"
fi
##
## End Container App create 
##
##############################################

##############################################
##
## Start Verify the API returns a result you expect
##

API_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $CONTAINER_APP_NAME --query properties.configuration.ingress.fqdn -o tsv)
API_BASE_URL="https://$API_BASE_URL/$SH_SMOKE_TEST_ENDPOINT"
CURL_RESULT=$(curl $API_BASE_URL)
#echo $CURL_RESULT
if [[ $CURL_RESULT = *$SH_SMOKE_TEST_TEXT* ]]
then
    echo "Successfully accessed the API $API_BASE_URL"
else
    echo "Failed to access the API $API_BASE_URL"
    echo $CURL_RESULT
fi
##
## End Verify the API returns a result you expect
##
##############################################

cd "$SH_DRIVER_ROOT"
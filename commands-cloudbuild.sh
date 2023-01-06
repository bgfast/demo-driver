#!/bin/bash

FILENAME="https://github.com/Azure-Samples/containerapps-albumapi-csharp/archive/refs/heads/main.zip"
mkdir ./containerapps-albumapi-csharp
cd ./containerapps-albumapi-csharp
#curl -sS http://foo.bar/filename.zip > file.zip
curl -SL $FILENAME > file.zip
unzip -d . file.zip 
rm file.zip
cd ./containerapps-albumapi-csharp-main/src
pwd

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


#. ./commands.secure.sh
# to do create the secrets file and import it here

# Quickstart: Deploy your code to Azure Container Apps - Cloud build
# https://learn.microsoft.com/en-us/azure/container-apps/quickstart-code-to-cloud?tabs=bash%2Ccsharp&pivots=acr-remote


#az login
#az account set --subscription $SUBSCRIPTIONID
#az upgrade

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
UNIQUE_ID="3"
VERBOSEDEBUG=true
RESOURCE_GROUP="rg-containerapp-$UNIQUE_ID"
LOCATION="westus"
ENVIRONMENT="env-album-containerapps"
CONTAINER_APP_NAME="album-api"
IMAGE_NAME="album-api-go"
FRONTEND_NAME="album-ui"
GITHUB_USERNAME="bgfast"
CUSERNAME="crbrent$UNIQUE_ID"
# Define a container registry name unique to you.
ACR_NAME="crbrent$UNIQUE_ID"

# https://github.com/Azure-Samples/azure-cli-samples/blob/master/container-registry/create-registry/create-registry-service-principal-assign-role.sh
# Get the details of the registry 
# https://stackoverflow.com/questions/43373176/store-json-directly-in-bash-script-with-variables
# asset_ID=$( curl '...' | jq --raw-output '.AssetID' )
# https://stackoverflow.com/questions/47018863/parsing-and-storing-the-json-output-of-a-curl-command-in-bash
#declare -a CIE_ACR

###################################################
# check for and create the resource group
#

if $VERBOSEDEBUG
then
    echo "Running command to check for resource group:"
    echo "az group exists -n $RESOURCE_GROUP"
    az group exists -n $RESOURCE_GROUP
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

#retVal=42
#return ${retVal} 2>/dev/null || exit "${retVal}"

#CIE_ACR = $(('az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP'))
# https://learn.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az-group-exists
#if $VERBOSEDEBUG
#then
#    echo "Running command:"
#    echo "az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP"
#    az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP
#fi
if $VERBOSEDEBUG
then
    az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP
fi
CIE_ACR=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP)
#echo ${CIE_ACR} # This doesn't render correctly- not sure why
if [[ $CIE_ACR = *creationDate* ]]
then
    echo "The Azure Container Registry already exists"
    CPASSWORD=$(az acr credential show -n $ACR_NAME --query passwords[0].value)
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
    echo "$(tput setaf 2)Exiting the script. You need to update the script with the username and password from the Azure Container Registry. "
    CPASSWORD=$(az acr credential show -n $ACR_NAME --query passwords[0].value)

    #return 42
fi

# Strip the quotes off the password
eval CPASSWORD=$CPASSWORD

# Build the container in Azure
# To do - how to know when the container needs to be rebuilt. Perhaps a flag on the script?
az acr build --registry $ACR_NAME --image $IMAGE_NAME --only-show-errors .

# https://learn.microsoft.com/en-us/cli/azure/containerapp/env?view=azure-cli-latest
if $VERBOSEDEBUG
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

# Check if the container app has already been created. If not, then create it. If yes, then update it
if $VERBOSEDEBUG
then
    az containerapp show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP
fi
CONTAINER_APP=$(az containerapp show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP)
if [[ $CONTAINER_APP = *$CONTAINER_APP_NAME* ]]
then
    echo "The Azure Container APP already exists. Updating the Container APP..."
    # Create the container app and deploy the image
    #az containerapp update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --image $ACR_NAME.azurecr.io/$IMAGE_NAME
    THERESULT=$(az containerapp update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --image $ACR_NAME.azurecr.io/$IMAGE_NAME)
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
    az containerapp create --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT --image $ACR_NAME.azurecr.io/$IMAGE_NAME --target-port 3500 --ingress 'external' --registry-server $ACR_NAME.azurecr.io --query properties.configuration.ingress.fqdn --registry-password $CPASSWORD --registry-username $CUSERNAME
fi

#############################

# Verify the API returns a result you expect
API_BASE_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name $CONTAINER_APP_NAME --query properties.configuration.ingress.fqdn -o tsv)
API_BASE_URL="https://$API_BASE_URL/albums"
CURL_RESULT=$(curl $API_BASE_URL)
#echo $CURL_RESULT
if [[ $CURL_RESULT = *MegaDNS* ]]
then
    echo "Successfully accessed the API $API_BASE_URL"
else
    echo "Failed to access the API $API_BASE_URL"
fi

#############################

cd ../../..

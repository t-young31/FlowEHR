#!/bin/bash
#  Copyright (c) University College London Hospitals NHS Foundation Trust
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o pipefail
set -o nounset

echo "Creating resource group..."
az group create --name $CORE_RESOURCE_GROUP --location $ARM_LOCATION

echo "Creating storage account..."
az storage account create --resource-group $CORE_RESOURCE_GROUP --name $CORE_STORAGE_ACCOUNT --sku Standard_LRS --encryption-services blob

echo "Creating blob container for TF state..."
az storage container create --name $TF_BACKEND_CONTAINER --account-name $CORE_STORAGE_ACCOUNT --auth-mode login -o table

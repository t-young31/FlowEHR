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
#  limitations under the License.

resource "azurerm_application_insights" "serve" {
  name                = "aml-ai-${var.naming_suffix}"
  location            = var.core_rg_location
  resource_group_name = var.core_rg_name
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_storage_account" "serve" {
  name                     = "strgaml${var.truncated_naming_suffix}"
  location                 = var.core_rg_location
  resource_group_name      = var.core_rg_name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = var.tags
}

resource "azurerm_machine_learning_workspace" "serve" {
  count = 0
  # TODO: remove


  name                    = "aml-${var.naming_suffix}"
  location                = var.core_rg_location
  resource_group_name     = var.core_rg_name
  application_insights_id = azurerm_application_insights.serve.id
  key_vault_id            = var.core_kv_id
  storage_account_id      = azurerm_storage_account.serve.id
  tags                    = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_service_plan" "test" {
  name                = "asp-test-${var.naming_suffix}"
  location            = var.core_rg_location
  resource_group_name = var.core_rg_name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "test" {
  name                = "asp-app-${var.naming_suffix}"
  location            = var.core_rg_location
  resource_group_name = var.core_rg_name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    always_on  = true
    ftps_state = "Disabled"

    # application_stack {
    #   docker_image     = ""
    #   docker_image_tag = ""
    # }
  }

  app_settings = {
    "STATE_STORE_ENDPOINT"  = azurerm_cosmosdb_account.test.endpoint
    "COSMOSDB_ACCOUNT_NAME" = azurerm_cosmosdb_account.test.name
    "GOLD_STORE_FDQN"       = azurerm_mssql_server.gold_store.fully_qualified_domain_name
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "cosmos-db-${var.naming_suffix}"
  location            = var.core_rg_location
  resource_group_name = var.core_rg_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = var.core_rg_location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_role_definition" "reader" {
  name                = "testsqlroledef"
  resource_group_name = var.core_rg_name
  type                = "CustomRole"
  account_name        = azurerm_cosmosdb_account.test.name
  assignable_scopes   = [azurerm_cosmosdb_account.test.id]

  permissions {
    data_actions = ["Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*"]
  }
}

resource "random_uuid" "web_app_reader" {}

resource "azurerm_cosmosdb_sql_role_assignment" "web_app_reader" {
  name                = random_uuid.web_app_reader.result
  resource_group_name = var.core_rg_name
  account_name        = azurerm_cosmosdb_account.test.name
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.reader.id
  principal_id        = azurerm_linux_web_app.test.identity.0.principal_id
  scope               = azurerm_cosmosdb_account.test.id
}

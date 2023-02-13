
resource "azurerm_mssql_server" "gold_store" {
  name                = "flowehrgoldstore"
  location            = var.core_rg_location
  resource_group_name = var.core_rg_name
  version             = "12.0"
  minimum_tls_version = "1.2"
  # public_network_access_enabled = false

  azuread_administrator {
    login_username              = "adminuser"
    object_id                   = data.azurerm_client_config.current.object_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_database" "test" {
  name           = "testdb"
  server_id      = azurerm_mssql_server.gold_store.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "Basic"
  zone_redundant = false
}


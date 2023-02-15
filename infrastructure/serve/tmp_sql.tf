
resource "azurerm_mssql_server" "test" {
  name                = "mssql-test-${var.naming_suffix}"
  location            = var.core_rg_location
  resource_group_name = var.core_rg_name
  version             = "12.0"
  minimum_tls_version = "1.2"
  # public_network_access_enabled = false

  administrator_login          = "adminuser"
  administrator_login_password = "Ta+HiCPpqCztI4wpJCiinUJ5ZHky7bYAqy8ZyIppu78"

  azuread_administrator {
    login_username = "adminuserad"
    object_id      = data.azurerm_client_config.current.object_id
  }

}

#yolo
resource "azurerm_mssql_firewall_rule" "test" {
  name             = "AllowAll"
  server_id        = azurerm_mssql_server.test.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_mssql_database" "test" {
  name           = "testdb"
  server_id      = azurerm_mssql_server.test.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "Basic"
  zone_redundant = false
}

data "external" "sql_access_token" {
  program = ["az", "account", "get-access-token", "--resource", "https://database.windows.net"]
}

resource "azurerm_container_group" "data_plane_access" {
  name                = "cg-test"
  location            = var.core_rg_location
  resource_group_name = var.core_rg_name
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name   = "mssql"
    image  = "tyoung31/powershell-sqlcmd"
    cpu    = "1"
    memory = "4"
    # commands = ["tail", "-f", "/dev/null"]
    commands = ["pwsh",
      "-Command",
      <<EOF
    Invoke-Sqlcmd -ServerInstance "${azurerm_mssql_server.test.fully_qualified_domain_name}" -AccessToken "${data.external.sql_access_token.result.accessToken}" -Database "${azurerm_mssql_database.test.name}" -Query "CREATE USER ""${azurerm_linux_web_app.test.name}"" FROM EXTERNAL PROVIDER;"
    EOF
    ]

    ports { # unused but must be defined 
      port     = 22
      protocol = "TCP"
    }
  }
}

include "root" {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../core"]
}

inputs = {
  core_rg_name     = dependency.core.outputs.core_rg_name
  core_rg_location = dependency.core.outputs.core_rg_location
}

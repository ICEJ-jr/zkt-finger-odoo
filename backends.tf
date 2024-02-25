terraform {
  cloud {
    organization = "icej-org"

    workspaces {
      name = "odoo-16"
    }
  }
}
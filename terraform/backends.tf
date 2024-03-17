terraform {
  cloud {
    organization = "icej-org"

    workspaces {
      name = "jay-mocks-server"
    }
  }
}
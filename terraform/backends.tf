terraform {
  cloud {
    organization = "icej-org"

    workspaces {
      name = "zkt"
    }
  }
}
terraform {
  cloud {
    organization = "denno2340"

    workspaces {
      name = "denno-workspace"
    }
  }
}
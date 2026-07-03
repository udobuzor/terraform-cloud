terraform {
  cloud {
    organization = "oddshare-infra"

    workspaces {
      name = "terraform-cloud"
    }
  }
}




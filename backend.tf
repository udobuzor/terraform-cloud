terraform {
  cloud {
    organization = "oddshare-infra"

    workspaces {
      name = "your-workspace-name"
    }
  }
}




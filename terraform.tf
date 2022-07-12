terraform {
  cloud {
    organization = "DokiLAB"

    workspaces {
      name = "Splunk"
    }
  }
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.1.1"
    }
  }

}


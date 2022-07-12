provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "MYLab-DC"
}

data "vsphere_datastore" "datastore" {
  name          = "LUN_SSD"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "production_template" {
  name          = "Templates/CentOS7-Vault"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "MYLab-Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "DSwitch-VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "Splunk"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  firmware         = data.vsphere_virtual_machine.production_template.firmware


  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.production_template.guest_id

  scsi_type = data.vsphere_virtual_machine.production_template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.production_template.network_interface_types[0]
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.production_template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.production_template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.production_template.id
    linked_clone  = true
    customize {
      linux_options {
        host_name = "splunk"
        domain    = "doki.lab"
      }
      network_interface {}
    }
  }
}

variable "vnets" {
  type = list(object({
    name  = string
    region  = string
    cidr = list(string)
    subnet = list(string)
    nsg = string
  }))

  default = [{
    name = "vnet-1"
    region = "eastus"
    cidr = ["10.0.0.0/16"]
    subnet = ["10.0.2.0/24"]
    nsg = "nsg-1"
  },
  {
    name = "vnet-2"
    region = "eastus2"
    cidr = ["10.1.0.0/16"]
    subnet = ["10.1.2.0/24"]
    nsg = "nsg-2"
  },
  {
    name = "vnet-3"
    region = "westus2"
    cidr = ["10.2.0.0/16"]
    subnet = ["10.2.2.0/24"]
    nsg = "nsg-3"
  }]

  description = <<EOF
    Specifies one or more virtual networks that will be deployed 
      name       - (Required) Name of Virtual Network
      region     - (Required) The region where it will be deployed
      vnet       - (Required) The vnet CIDR block
      subnet     - (Required) The subnet that will be created into Virtual Network (Only one subnet per Vnet)
      nsg        - (Required) The NSG that will be attached to the subnet
  EOF
}

variable "instance_set" {

  type = list(object({
    name  = string
    region  = string
    vnet = string
    node-type = string
  }))

  default = [{
    name = "instance-1"
    region = "eastus"
    vnet = "vnet-1"
    node-type = "main"
  }, 
  {
    name = "instance-2"
    region = "eastus"
    vnet = "vnet-1"
    node-type = "worker"
  },
  {
    name = "instance-3"
    region = "eastus2"
    vnet = "vnet-2"
    node-type = "manager"
  },
  {
    name = "instance-4"
    region = "eastus2"
    vnet = "vnet-2"
    node-type = "worker"
  },
  {
    name = "instance-5"
    region = "westus2"
    vnet = "vnet-3"
    node-type = "worker"
  },
  {
    name = "instance-6"
    region = "westus2"
    vnet = "vnet-3"
    node-type = "worker"
  },
  {
    name = "instance-7"
    region = "eastus2"
    vnet = "vnet-2"
    node-type = "manager"
  },
  {
    name = "instance-8"
    region = "eastus"
    vnet = "vnet-1"
    node-type = "worker"
  }
  ]
  description = <<EOF
    Specifies one or more virtual machines
      name       - (Required) Name of Virtual Machine
      region     - (Required) The region where it will be deployed
      vnet       - (Required) The vnet where it will be lived
      node-type  - (Required) "Specify the role of the virtual machine within the Docker cluster. The values can be:

                              Main: the virtual machine that will set up the Docker Swarm cluster
                              Manager: the node(s) that will act as manager nodes
                              Worker: the node(s) that will act as worker nodes
  EOF
}

#some
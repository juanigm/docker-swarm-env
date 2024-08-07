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
  }
  ]
}
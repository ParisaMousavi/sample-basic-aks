variable "location" {
  type    = string
  default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "sample"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "name" {
  type    = string
  default = "basicaks"
}

variable "location_shortname" {
  type    = string
  default = "weu"
}

variable "tenant_id" {
  type = string
}

variable "connect_to_arc" {
  type    = bool
  default = true
}
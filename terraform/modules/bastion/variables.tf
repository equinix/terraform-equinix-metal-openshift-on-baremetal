variable "auth_token" {
    description = "Packet API Key"
    type = string
}

variable "project_id" {
    description = "Packet Project ID"
    type = string
}

variable "operating_system" {
    description = "The Operating system of the server"
    default = "centos_8"
    type = string
}

variable "billing_cycle" {
    description = "How the node will be billed (Not usually changed)"
    default = "hourly"
    type = string
}

variable "plan"{
    description = "The server type to deploy"
    default = "c3.medium.x86"
    type = string
}

variable "facility" {
    description = "The location of the servers"
    default = "sjc1"
    type = string
}


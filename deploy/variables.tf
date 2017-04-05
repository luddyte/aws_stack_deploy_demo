variable "region" {
  description = "The AWS region"
  default     = "us-east-1"
}

variable "key_name" {
  description = "The AWS key pair to use for resources"
  default     = "ehron"
}

# using agent
#variable "key_path" {
#description = "Private key path to use for provsioners"
#}

variable "ami" {
  type = "map"

  # Ubuntu 16.04
  default = {
    us-east-1 = "ami-4dd2575b"
    us-west-1 = "ami-e6095386"
  }
}

variable "instance_type" {
  description = "The AWS instance size"
  default     = "t2.micro"
}

# looks like lists aren't valid map values so breaking it up
#variable "instance_ips" {
#type = "map"
#description = "The IPs to use for our instances"
#default     = {
#  web =    ["10.0.1.20", "10.0.1.21"]
#  db  =    ["10.0.1.22"]
#  server = ["10.0.1.23"]
#}

variable web_ips {
  description = "Addresses of web instances"
  default     = ["10.0.1.20", "10.0.1.21"]
}

variable db_ips {
  description = "Addresses of DB instances"
  default     = ["10.0.1.22"]
}

variable server_ips {
  description = "Addresses of server instances"
  default     = ["10.0.1.23"]
}

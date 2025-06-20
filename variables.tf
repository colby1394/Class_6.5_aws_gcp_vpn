# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "project_id" {
  type = string
  default = "Change_me"
  description = "value of the project id"
  
}

variable "vpn_gwy_region" {
  type = string
  default = "us-central1"
  description = "Region where the GCP VPN gateway will be created."
  
}

variable "gcp_router_asn" {
  type = string
  default = "65515"
  description = "ASN for the GCP router."
}

variable "aws_router_asn" {
  type = string
  default = "65001"
  description = "ASN for the AWS router."
}

variable "aws_vpc_id" {
  type = string
  default = "Change_me"
  description = "ID of the AWS VPC."
}

variable "gcp_network" {
  type        = string
  description = "Name of the GCP network you want to use."
  default     = "default"

}

variable "aws_vpc_cidr" {
  type = string
  default = "10.220.0.0/16"
  description = "CIDR range of the AWS VPC."
}



variable "shared_secret" {
  type = string
  default = "Change_me"
  description = "Shared secret for the VPN tunnel."
}

variable "shared_secret2" {
  type = string
  default = "Change_me"
  description = "Shared secret for the VPN tunnel."
  
}

variable "prefix" {
  type        = string
  description = "Prefix used for all the resources."
  default     = "gcp-aws-vpn"
}

variable "num_tunnels" {
  type = number
  default = 4
  validation {
    condition     = var.num_tunnels % 2 == 0
    error_message = "number of tunnels needs to be in multiples of 2."
  }
  validation {
    condition     = var.num_tunnels >= 4
    error_message = "min 4 tunnels required for high availability."
  }
  description = <<EOF
    Total number of VPN tunnels. This needs to be in multiples of 2.
  EOF
}
variable "project_id" {
  description = "The ID of the project where this VPC will be created"
  type        = string
}

variable "network_name" {
  description = "The name of the network being created"
  type        = string
}

variable "routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "The network routing mode (default 'GLOBAL')"
}

variable "shared_vpc_host" {
  type        = bool
  description = "Makes this project a Shared VPC host if 'true' (default 'false')"
  default     = false
}

variable "psa_prefix_length" {
  description = "Prefix length for Private Service Access IP range"
  type        = number
  default     = 16
}

variable "description" {
  type        = string
  description = "An optional description of this resource. The resource must be recreated to modify this field."
  default     = ""
}

variable "auto_create_subnetworks" {
  type        = bool
  description = "When set to true, the network is created in 'auto subnet mode' and it will create a subnet for each region automatically across the 10.128.0.0/9 address range. When set to false, the network is created in 'custom subnet mode' so the user can explicitly connect subnetwork resources."
  default     = false
}

variable "delete_default_internet_gateway_routes" {
  type        = bool
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted"
  default     = false
}

variable "mtu" {
  type        = number
  description = "The network MTU (If set to 0, meaning MTU is unset - defaults to '1460'). Recommended values: 1460 (default for historic reasons), 1500 (Internet default), or 8896 (for Jumbo packets). Allowed are all values in the range 1300 to 8896, inclusively."
  default     = 1460
}

variable "enable_ipv6_ula" {
  type        = bool
  description = "Enabled IPv6 ULA, this is a permenant change and cannot be undone! (default 'false')"
  default     = false
}

variable "internal_ipv6_range" {
  type        = string
  default     = null
  description = "When enabling IPv6 ULA, optionally, specify a /48 from fd20::/20 (default null)"
}

variable "network_firewall_policy_enforcement_order" {
  type        = string
  default     = null
  description = "Set the order that Firewall Rules and Firewall Policies are evaluated. Valid values are `BEFORE_CLASSIC_FIREWALL` and `AFTER_CLASSIC_FIREWALL`. (default null or equivalent to `AFTER_CLASSIC_FIREWALL`)"
}


variable "network_profile" {
  type        = string
  default     = null
  description = <<-EOT
    "A full or partial URL of the network profile to apply to this network.
    This field can be set only at resource creation time. For example, the
    following are valid URLs:
      * https://www.googleapis.com/compute/beta/projects/{projectId}/global/networkProfiles/{network_profile_name}
      * projects/{projectId}/global/networkProfiles/{network_profile_name}
    EOT
}

variable "subnetworks" {
  description = "A list of subnetworks to create"
  type = list(object({
    name          = string
    region        = string
    ip_cidr_range = string
    private_ip_google_access  = optional(bool, false)  # Default false
    secondary_ip_ranges      = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
}


variable "connectors" {
  description = "A list of VPC access connector to create"
  type = list(object({
    name          = string
    region        = string
    subnet_name   = string
    machine_type  = string
    min_instances = number
    max_instances = number
  }))
  default = []
}

variable "firewall_rules" {
  description = "A list of firewall rules to create"
  type = list(object({
    name        = string
    direction   = optional(string, "INGRESS")
    priority    = optional(number, 1000)
    ranges      = list(string)
    target_tags = optional(list(string), [])
    allow       = list(object({
      protocol = string
      ports    = optional(list(string), [])
    }))
    deny        = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = []
}

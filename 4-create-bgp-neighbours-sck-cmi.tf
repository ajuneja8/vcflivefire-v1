terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
      version = "3.3.0"
      configuration_aliases = [ nsxt.alternate ]
    }
  }
}

provider "nsxt" {
  alias                = "lm-cmi-rec"
  host                 = "10.0.0.21"
  username             = "admin"
  password             = "VMware123!VMware123!"
  allow_unverified_ssl = true
}

provider "nsxt" {
  alias                = "lm-sck-pri"
  host                 = "10.0.20.21"
  username             = "admin"
  password             = "VMware123!VMware123!"
  allow_unverified_ssl = true
}
provider "nsxt" {
  host                  = "10.0.20.31"
  username              = "admin"
  password              = "VMware123!VMware123!"
  #alias                 = "gm-cmi-rec"
  global_manager        = true
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
}


data "nsxt_policy_site" "lm-cmi-rec" {
  display_name = "lm-cmi-rec"
}
data "nsxt_policy_site" "lm-sck-pri" {
  display_name = "lm-sck-pri"
}
data "nsxt_policy_tier0_gateway" "Global-T0" {
  display_name = "Global-T0"
}
data "nsxt_policy_gateway_locale_service" "lm-cmi-rec" {
  gateway_path = data.nsxt_policy_tier0_gateway.Global-T0.path
  display_name = "lm-cmi-rec"
}
data "nsxt_policy_gateway_locale_service" "lm-sck-pri" {
  gateway_path = data.nsxt_policy_tier0_gateway.Global-T0.path
  display_name = "lm-sck-pri"
}
resource "nsxt_policy_bgp_neighbor" "ToR-A-cmi-rec" {
    display_name        = "ToR-A-cmi-rec"
    bgp_path              = data.nsxt_policy_gateway_locale_service.lm-cmi-rec.path
    neighbor_address    = "192.168.253.1"
    remote_as_num       = "65100"
    }

resource "nsxt_policy_bgp_neighbor" "ToR-B-cmi-rec" {
    display_name        = "ToR-B-cmi-rec"
    bgp_path              = data.nsxt_policy_gateway_locale_service.lm-cmi-rec.path
    neighbor_address    = "192.168.254.1"
    remote_as_num       = "65100"
   
}


resource "nsxt_policy_bgp_neighbor" "ToR-A-sck-pri" {
    display_name        = "ToR-A-sck-pri"
    bgp_path              = data.nsxt_policy_gateway_locale_service.lm-sck-pri.path
    neighbor_address    = "192.168.253.129"
    remote_as_num       = "65100"
    }

resource "nsxt_policy_bgp_neighbor" "ToR-B-sck-pri" {
    display_name        = "ToR-B-sck-pri"
    bgp_path              = data.nsxt_policy_gateway_locale_service.lm-sck-pri.path
    neighbor_address    = "192.168.254.129"
    remote_as_num       = "65100"
   
}






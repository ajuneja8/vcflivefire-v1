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

data "nsxt_policy_transport_zone" "mgmt-domain-tz-overlay01" {
  display_name = "mgmt-domain-tz-overlay01"
  site_path    = data.nsxt_policy_site.lm-sck-pri.path
}

data "nsxt_policy_edge_cluster" "EC-01" {
  display_name = "EC-01"
  site_path    = data.nsxt_policy_site.lm-cmi-rec.path
}

data "nsxt_policy_edge_cluster" "EC-02" {
  display_name = "EC-02"
  site_path    = data.nsxt_policy_site.lm-sck-pri.path
}

data "nsxt_policy_edge_node" "edge1-mgmt" {
    edge_cluster_path   = data.nsxt_policy_edge_cluster.EC-01.path
    display_name        = "edge1-mgmt"
}

data "nsxt_policy_edge_node" "edge2-mgmt" {
    edge_cluster_path   = data.nsxt_policy_edge_cluster.EC-01.path
    display_name        = "edge2-mgmt"
}


resource "nsxt_policy_tier0_gateway" "global_t0" {
  display_name  = "Global-T0"
  nsx_id        = "Global-T0"
  description   = "Tier-0 with Global scope"
  failover_mode = "NON_PREEMPTIVE"
  locale_service {
    edge_cluster_path = data.nsxt_policy_edge_cluster.EC-01.path
  }
  locale_service {
    edge_cluster_path = data.nsxt_policy_edge_cluster.EC-02.path
  }
  tag {
    tag = "terraform"
  }
}

resource "nsxt_policy_gateway_redistribution_config" "lm-cmi-rec-redistribute" {
  gateway_path = nsxt_policy_tier0_gateway.global_t0.path
  site_path    = data.nsxt_policy_site.lm-cmi-rec.path
  bgp_enabled = true
  rule {
    name  = "cmi-rule-1"
    types = ["TIER1_CONNECTED", "TIER1_LB_VIP"]
  }
}
resource "nsxt_policy_gateway_redistribution_config" "lm-sck-pri-redistribute" {
  gateway_path = nsxt_policy_tier0_gateway.global_t0.path
  site_path    = data.nsxt_policy_site.lm-sck-pri.path
  bgp_enabled = true
  rule {
    name  = "sck-rule-1"
    types = ["TIER1_CONNECTED", "TIER1_LB_VIP"]
  }
}


resource "nsxt_policy_tier1_gateway" "global_t1" {
  description  = "Tier-1 provisioned by Terraform"
  display_name = "Global-T1"
  route_advertisement_types = ["TIER1_CONNECTED"]
  tier0_path   = nsxt_policy_tier0_gateway.global_t0.path
    locale_service {
  edge_cluster_path = data.nsxt_policy_edge_cluster.EC-01.path
                    }
    locale_service {
  edge_cluster_path = data.nsxt_policy_edge_cluster.EC-02.path
                   }
   intersite_config {
    primary_site_path = data.nsxt_policy_site.lm-sck-pri.path
  }
}

resource "nsxt_policy_segment" "ov-web" {
  display_name        = "ov-web"
  nsx_id              = "ov-web"
  connectivity_path   = nsxt_policy_tier1_gateway.global_t1.path
  subnet {
    cidr = "172.16.10.1/24"
  }
  advanced_config {
    connectivity = "ON"
  }
}
resource "nsxt_policy_segment" "ov-db" {
  display_name        = "ov-db"
  nsx_id              = "ov-db"
  connectivity_path   = nsxt_policy_tier1_gateway.global_t1.path
  subnet {
    cidr = "172.16.20.1/24"
  }
  advanced_config {
    connectivity = "ON"
  }
}




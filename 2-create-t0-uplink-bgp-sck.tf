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

data "nsxt_policy_site" "lm-sck-pri" {
  display_name = "lm-sck-pri"
}

    
data "nsxt_policy_transport_zone" "VCF-edge_EC-01_uplink-tz" {
  display_name = "VCF-edge_EC-01_uplink-tz"
  site_path    = data.nsxt_policy_site.lm-sck-pri.path
}
    

data "nsxt_policy_edge_cluster" "EC-02" {
   site_path    = data.nsxt_policy_site.lm-sck-pri.path
   display_name = "EC-02"
}

# Edge Nodes
data "nsxt_policy_edge_node" "edge1-mgmt" {
    edge_cluster_path   = data.nsxt_policy_edge_cluster.EC-02.path
    display_name        = "edge1-mgmt"
}

data "nsxt_policy_edge_node" "edge2-mgmt" {
    edge_cluster_path   = data.nsxt_policy_edge_cluster.EC-02.path
    display_name        = "edge2-mgmt"
}

data "nsxt_policy_tier0_gateway" "Global-T0" {
  display_name = "Global-T0"
}

# Create VLAN Segments
resource "nsxt_policy_vlan_segment" "vlan-300" {
    display_name = "vlan-300"
    description = "VCF 1 N/S VLAN Segment"
    transport_zone_path = data.nsxt_policy_transport_zone.VCF-edge_EC-01_uplink-tz.path
    advanced_config {
         uplink_teaming_policy = "VCF-edge_EC-01_uplink1-named-teaming-policy"
    }
    vlan_ids = ["300"]
}

resource "nsxt_policy_vlan_segment" "vlan-400" {
    display_name = "vlan-400"
    description = "VCF 1 N/S VLAN Segment"
    transport_zone_path = data.nsxt_policy_transport_zone.VCF-edge_EC-01_uplink-tz.path
    advanced_config {
         uplink_teaming_policy = "VCF-edge_EC-01_uplink2-named-teaming-policy"
    }
    vlan_ids = ["400"]
}

# Create lm-sck-pri Tier-0 Gateway Uplink Interfaces

resource "nsxt_policy_tier0_gateway_interface" "vlan-300-edge1-mgmt" {
    display_name        = "vlan-300-edge1-mgmt"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge1-mgmt.path
    gateway_path        = data.nsxt_policy_tier0_gateway.Global-T0.path
    segment_path        = nsxt_policy_vlan_segment.vlan-300.path
    site_path           = data.nsxt_policy_site.lm-sck-pri.path
    subnets             = ["192.168.253.130/25"]
    mtu                 = 1500
}

resource "nsxt_policy_tier0_gateway_interface" "vlan-300-edge2-mgmt" {
    display_name        = "vlan-300-edge2-mgmt"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge2-mgmt.path
    gateway_path        = data.nsxt_policy_tier0_gateway.Global-T0.path
    segment_path        = nsxt_policy_vlan_segment.vlan-300.path
    site_path           = data.nsxt_policy_site.lm-sck-pri.path
    subnets             = ["192.168.253.131/25"]
    mtu                 = 1500
}
resource "nsxt_policy_tier0_gateway_interface" "vlan-400-edge1-mgmt" {
    display_name        = "vlan-400-edge1-mgmt"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge1-mgmt.path
    gateway_path        = data.nsxt_policy_tier0_gateway.Global-T0.path
    segment_path        = nsxt_policy_vlan_segment.vlan-400.path
    site_path           = data.nsxt_policy_site.lm-sck-pri.path
    subnets             = ["192.168.254.130/25"]
    mtu                 = 1500
}

resource "nsxt_policy_tier0_gateway_interface" "vlan-400-edge2-mgmt" {
    display_name        = "vlan-400-edge2-mgmt"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge2-mgmt.path
    gateway_path        = data.nsxt_policy_tier0_gateway.Global-T0.path
    segment_path        = nsxt_policy_vlan_segment.vlan-400.path
    site_path           = data.nsxt_policy_site.lm-sck-pri.path
    subnets             = ["192.168.254.131/25"]
    mtu                 = 1500
}
resource "nsxt_policy_bgp_config" "bgp-sck" {
  site_path    = data.nsxt_policy_site.lm-sck-pri.path
  gateway_path = data.nsxt_policy_tier0_gateway.Global-T0.path
  enabled                = true
  inter_sr_ibgp          = true
  local_as_num           = 65002
  graceful_restart_mode  = "HELPER_ONLY"
  
}
resource "nsxt_policy_bgp_neighbor" "ToR-A-sck-pri" {
    display_name        = "ToR-A-sck-pri"
    bgp_path              = nsxt_policy_bgp_config.bgp-sck.path
    neighbor_address    = "192.168.253.129"
    remote_as_num       = "65100"
    }

resource "nsxt_policy_bgp_neighbor" "ToR-B-sck-pri" {
    display_name        = "ToR-B-sck-pri"
    bgp_path              = nsxt_policy_bgp_config.bgp-sck.path
    neighbor_address    = "192.168.254.129"
    remote_as_num       = "65100"
   
}

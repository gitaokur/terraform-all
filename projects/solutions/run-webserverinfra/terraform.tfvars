# ==========================================
# Run-Webserverinfra Project Configuration
# ==========================================

# --- GLOBAL SETTINGS ---
project_id = "alperenokur-sandbox-415013" # [required]

# --- NETWORK MODULE ---
network_name = "serverless-vpc" # [required]
routing_mode = "GLOBAL"         # [optional] [default: GLOBAL]
shared_vpc_host = false         # [optional] [default: false]
psa_prefix_length = 16          # [optional] [default: 16]
network_description = ""        # [optional] [default: ""]
auto_create_subnetworks = false # [optional] [default: false]
delete_default_internet_gateway_routes = false # [optional] [default: false]
mtu = 1460                      # [optional] [default: 1460]
enable_ipv6_ula = false         # [optional] [default: false]
internal_ipv6_range = null      # [optional] [default: null]
network_firewall_policy_enforcement_order = null # [optional] [default: null]
network_profile = null          # [optional] [default: null]

subnetworks = [
  {
    name                     = "serverless-subnet"
    region                   = "europe-west1"
    ip_cidr_range            = "10.0.10.0/24"
    private_ip_google_access = true # [optional] [default: false]
    secondary_ip_ranges      = [
      {
        range_name    = "pods"
        ip_cidr_range = "10.0.11.0/24"
      }
    ] # [optional] [default: []]
  }
] # [required]

connectors = [
  {
    name          = "serverless-vpc-connector"
    region        = "europe-west1"
    subnet_name   = "serverless-subnet"
    machine_type  = "e2-micro"
    min_instances = 2
    max_instances = 3
  }
] # [optional] [default: []]

firewall_rules = [
  {
    name      = "allow-all-ingress"
    direction = "INGRESS" # [optional] [default: INGRESS]
    priority  = 1000      # [optional] [default: 1000]
    ranges    = ["0.0.0.0/0"]
    target_tags = ["internal"] # [optional] [default: []]
    allow = [
      {
        protocol = "all"
        ports    = [] # [optional] [default: []]
      }
    ]
    deny = [] # [optional] [default: []]
  }
] # [optional] [default: []]

# --- ARTIFACT REGISTRY ---
artifact_repositories = [
  {
    name     = "website-repo"
    format   = "DOCKER"
    location = "europe-west1"
    cleanup_policies = [
      {
        id     = "delete-old-images"
        action = "DELETE"
        condition = {
          tag_state             = "TAGGED"   # [optional]
          tag_prefixes          = ["v"]       # [optional]
          package_name_prefixes = ["webapp"]  # [optional]
          older_than            = "2592000s" # [optional]
          newer_than            = null        # [optional]
        }
      }
    ] # [optional] [default: []]
  }
] # [optional] [default: []]

# --- CLOUDBUILD ---
cloudbuild_connections = [
  {
    name            = "github-connection"
    region          = "europe-west1"
    installation_id = 12345678            # [required]
    secret_id       = "github-token-secret" # [required]
    secret_version  = "latest"              # [optional] [default: latest]
  }
] # [optional] [default: []]

cloudbuild_repositories = [
  {
    name            = "website-app-repo"
    region          = "europe-west1"
    connection_name = "github-connection"
    remote_uri      = "https://github.com/user/repo.git"
  }
] # [optional] [default: []]

cloudbuild_triggers = [
  {
    name            = "main-trigger"
    description     = "Trigger for main branch" # [optional] [default: ""]
    region          = "europe-west1"
    filename        = "cloudbuild.yaml"
    included_files  = ["**"] # [optional] [default: []]
    service_account = null   # [optional] [default: null]
    github = {
      owner  = "user"
      name   = "repo"
      branch = "^main$"
    }
  }
] # [optional] [default: []]

# --- CLOUD Armor ---
armor_security_policy_name = "website-shield" # [optional] [default: "website-security-policy"]
armor_rules = [
  {
    priority    = 1000
    description = "Allow all (example)"
    action      = "allow"
    match = {
      versioned_expr = "SRC_IPS_V1" # [optional]
      expr = {
        expression = "origin.ip == '1.2.3.4'"
      } # [optional] [default: null]
      config = {
        src_ip_ranges = ["0.0.0.0/0"]
      } # [optional]
    }
    preview = false
  }
] # [optional] [default: []]

# --- CLOUD RUN ---
run_services = [
  {
    name                  = "website-backend"
    region                = "europe-west1"
    image                 = "gcr.io/cloudrun/hello"
    allow_unauthenticated = true    # [optional] [default: true]
    cpu                   = 1       # [optional] [default: 1]
    memory                = "512Mi" # [optional] [default: "512Mi"]
    concurrency           = 80      # [optional] [default: 80]
    max_instances         = 10      # [optional] [default: 10]
    min_instances         = 0       # [optional] [default: 0]
    env_vars = [
      {
        name  = "ENV"
        value = "prod"
      }
    ] # [optional] [default: []]
    vpc_connector       = null                   # [optional] [default: null]
    service_account     = ""                     # [optional] [default: ""]
    ingress             = "INGRESS_TRAFFIC_ALL"  # [optional] [default: "INGRESS_TRAFFIC_ALL"]
    cloud_sql_instances = []                     # [optional] [default: []]
    direct_vpc_egress = {
      network    = "serverless-vpc"
      subnetwork = "serverless-subnet"
    } # [optional] [default: null]
    timeout = "300s"           # [optional] [default: "300s"]
    labels  = { stage = "dev" } # [optional] [default: {}]
    startup_probe = {
      timeout_seconds   = 240
      period_seconds    = 10
      failure_threshold = 3
      tcp_socket = {
        port = 8080
      } # [optional]
      http_get = {
        path = "/health"
        port = 8080
      } # [optional]
    } # [optional] [default: null]
    liveness_probe = {
      timeout_seconds   = 10
      period_seconds    = 30
      failure_threshold = 3
      http_get = {
        path = "/health"
        port = 8080
      }
    } # [optional] [default: null]
  }
] # [required]

# --- CLOUD SQL ---
sql_enable_public_ip = false   # [optional] [default: false]
sql_maintenance_day  = 7       # [optional] [default: 7]
sql_maintenance_hour = 3       # [optional] [default: 3]
sql_update_track     = "stable" # [optional] [default: "stable"]

database = {
  app-db = {
    database_version    = "MYSQL_8_0"
    instance_name       = "serverless-db-v1"
    database_name       = "website_db"
    region              = "europe-west1"
    tier                = "db-f1-micro"
    private_network     = "serverless-vpc"
    db_user             = "webapp" # [optional] [default: "admin"]
    db_password         = null     # [optional] [default: null]
    deletion_protection = false    # [optional] [default: true]
    availability_type   = "ZONAL"  # [optional] [default: "ZONAL"]
    database_flags = [
      {
        name  = "max_connections"
        value = "100"
      }
    ] # [optional] [default: []]
    insights_config = {
      query_insights_enabled  = true # [optional] [default: true]
      query_string_length     = 1024 # [optional] [default: 1024]
      record_application_tags = true # [optional] [default: true]
      record_client_address   = false # [optional] [default: false]
    } # [optional] [default: {}]
  }
} # [required]

# --- CLOUD STORAGE ---
buckets = [
  {
    name          = "website-assets-static"
    storage_class = "STANDARD"
    location      = "europe-west1"
    lifecycle_rules = [
      {
        age_days = 30
      }
    ] # [optional] [default: []]
    versioning_enabled       = false     # [optional] [default: false]
    public_access_prevention = "enforced" # [optional] [default: "enforced"]
    cors = {
      origin          = ["*"]
      method          = ["GET", "HEAD"]
      response_header = ["*"]
      max_age_seconds = 3600
    } # [optional] [default: null]
    website = {
      main_page_suffix = "index.html"
      not_found_page   = "404.html"
    } # [optional] [default: null]
  }
] # [required]

# --- LOAD BALANCER ---
lb_name = "serverless-lb"      # [required]
https_redirect = true          # [optional] [default: true]
ssl            = true          # [optional] [default: true]
create_ssl_certificate = false # [optional] [default: false]
ssl_certificates = []          # [optional] [default: []]
managed_ssl_certificate_domains = [] # [optional] [default: []]

project_id   = "alperenokur-sandbox-415013"

# --- NETWORK MODULE ---
network_name = "website-vpc"

# Optional / Default Variables
# routing_mode                              = "REGIONAL" # optional - default
# shared_vpc_host                           = false    # optional - default
# psa_prefix_length                         = 16       # optional - default
# network_description                       = ""       # optional - default
# auto_create_subnetworks                   = false    # optional - default
# delete_default_internet_gateway_routes    = false    # optional - default
# mtu                                       = 1460     # optional - default
# enable_ipv6_ula                           = false    # optional - default
# internal_ipv6_range                       = null     # optional
# network_firewall_policy_enforcement_order = null     # optional
# network_profile                           = null     # optional

subnetworks = [
  {
    name                     = "website-subnet"
    region                   = "europe-west1"
    ip_cidr_range            = "10.0.1.0/24"
    private_ip_google_access = true # optional
    # secondary_ip_ranges      = []   # optional
  }
]

# connectors = [] # optional - default

# --- MANAGED INSTANCE GROUP MODULE ---
instance_groups = {
  web-mig = {
    region                  = "europe-west1"
    network                 = "website-vpc"
    subnetwork              = "website-subnet"
    target_size             = 1                # optional
    # machine_type            = "e2-medium"     # optional - default
    source_image            = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
    # tags                    = []              # optional
    # labels                  = {}              # optional
    metadata_startup_script = <<-EOT
      #!/bin/bash
      exec > >(tee /var/log/startup-script.log|logger -t startup-script -s 2>/dev/console) 2>&1

      apt-get update
      apt-get upgrade -y

      curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
      apt-get install -y nodejs

      sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

      wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

      apt-get update
      apt-get install -y postgresql-15 postgresql-contrib

      sudo -u postgres psql -c "ALTER USER postgres PASSWORD '123456';"

      apt install nginx -y
      systemctl start nginx
      systemctl enable nginx

      apt install ufw
      ufw --force enable

      ufw allow 80/tcp
      ufw allow 443/tcp
      ufw allow 22/tcp

      ufw reload

      npm install -g pm2

      echo "### KURULUM BAŞARIYLA TAMAMLANDI ###"
    EOT
    assign_external_ip      = true
    # service_account         = ""              # optional
  }
}

firewall_rules = [
  {
    name      = "allow-all-ingress"
    direction = "INGRESS"
    priority  = 1000
    ranges    = ["0.0.0.0/0"]
    allow = [
      {
        protocol = "all"
        ports    = []
      }
    ]
  },
  {
    name      = "allow-all-egress"
    direction = "EGRESS"
    priority  = 1000
    ranges    = ["0.0.0.0/0"]
    allow = [
      {
        protocol = "all"
        ports    = []
      }
    ]
  }
]

# --- LOAD BALANCER MODULE ---
lb_name = "website-lb"

# Optional / Default Variables
# https_redirect                  = true  # optional - default
# ssl                             = true  # optional - default
# create_ssl_certificate          = false # optional - default
# private_key                     = null  # optional
# certificate                     = null  # optional
# ssl_certificates                = []    # optional
# ssl_policy                      = null  # optional
# managed_ssl_certificate_domains = []    # optional
# random_certificate_suffix       = false # optional - default
# security_policy                 = null  # optional
# iap_config                      = { enabled = false } # optional - default

# --- CLOUD SQL MODULE ---
# sql_enable_public_ip = false # optional - default
# sql_maintenance_day  = 7     # optional - default
# sql_maintenance_hour = 3     # optional - default
# sql_update_track     = "stable" # optional - default

database = {
  main-db = {
    database_version = "MYSQL_8_0"
    instance_name    = "website-db-v3"
    database_name    = "website"
    region           = "europe-west1"
    tier             = "db-f1-micro"
    private_network  = "website-vpc"
    db_user          = "admin" # optional
    # db_password      = null    # optional
    # authorized_networks = []   # optional
    # backup_enabled      = true # optional - default
    # binary_log_enabled  = false # optional - default
    # disk_size           = 50    # optional - default
    deletion_protection = false # optional - default
  }
}

# --- CLOUD STORAGE MODULE ---
buckets = [
  {
    name          = "website-assets-bucket"
    storage_class = "STANDARD"
    location      = "europe-west1"
    # lifecycle_rules = [] # optional
  }
]

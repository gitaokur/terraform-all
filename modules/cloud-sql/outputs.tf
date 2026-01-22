output "database_instances" {
  value = {
    for k, v in google_sql_database_instance.default : k => {
      name            = v.name
      connection_name = v.connection_name
      private_ip      = v.private_ip_address
      public_ip       = v.public_ip_address
    }
  }
}

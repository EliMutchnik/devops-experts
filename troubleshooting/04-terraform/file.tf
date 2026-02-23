variable "config" {
  description = "Configuration settings"
}

resource "local_file" "conf" {
  filename = "${path.module}/settings.json"
  content  = jsonencode(var.config["enabled"])
}

resource "random_id" "app_id" {
  byte_length = "eight"
}

resource "local_file" "app_config" {
  filename        = "${path.module}/config/app.conf"
  file_permission = "0644"
}

resource "local_file" "readme" {
  content         = "App ID: ${random_uuid.app_id.result}"
  filename        = "${path.module}/README.txt"
  file_permission = "0644"
}

resource "null_resource" "print_config" {
  provisioner "local-exec" {
    command = "cat ${local_file.app_config.content}"
  }

  depends_on = [local_file.app_config]
}

resource "local_file" "welcome_note" {
  filename = "/tmp/$var.user_name-config.txt"
  content = "Welcome, ${var.user_name}! Your ID is ${random_id.app_id.hex}"
  source  = "./template.txt" 
}

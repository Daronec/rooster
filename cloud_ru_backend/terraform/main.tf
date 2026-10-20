# Cloud.ru Advanced Terraform Configuration
# Развёртывание: ВМ + API Gateway + PostgreSQL

terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/infrastructure/cloudru"
      version = ">= 1.0.0"
    }
  }
}

# ==================== Providers ====================

provider "cloudru" {
  endpoint = "https://api.cloud.ru"
  token    = var.cloudru_token
  project  = var.project_id
  zone     = var.zone
}

# ==================== Variables ====================

variable "cloudru_token" {
  description = "Cloud.ru API token"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "Cloud.ru project ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-1a"
}

variable "vm_name" {
  description = "VM name for backend"
  type        = string
  default     = "rooster-backend"
}

variable "vm_platform_id" {
  description = "VM platform ID"
  type        = string
  default     = "standard-v3"
}

variable "vm_cores" {
  description = "VM CPU cores"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "VM memory in GB"
  type        = number
  default     = 4
}

variable "vm_disk_size" {
  description = "VM disk size in GB"
  type        = number
  default     = 20
}

variable "postgres_name" {
  description = "PostgreSQL cluster name"
  type        = string
  default     = "rooster-postgres"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = number
  default     = 15
}

variable "postgres_disk_size" {
  description = "PostgreSQL disk size in GB"
  type        = number
  default     = 20
}

variable "postgres_memory" {
  description = "PostgreSQL memory in GB"
  type        = number
  default     = 4
}

variable "postgres_cores" {
  description = "PostgreSQL CPU cores"
  type        = number
  default     = 2
}

variable "api_gateway_name" {
  description = "API Gateway name"
  type        = string
  default     = "rooster-api-gateway"
}

variable "api_gateway_domain" {
  description = "API Gateway domain"
  type        = string
  default     = "api.rooster.cloud.ru"
}

# ==================== Network ====================

resource "cloudru_vpc_network" "rooster_network" {
  name = "rooster-network"
}

resource "cloudru_vpc_subnet" "rooster_subnet" {
  name           = "rooster-subnet"
  network_id     = cloudru_vpc_network.rooster_network.id
  zone           = var.zone
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "cloudru_vpc_security_group" "vm_security_group" {
  name       = "rooster-vm-sg"
  network_id = cloudru_vpc_network.rooster_network.id

  ingress {
    protocol    = "TCP"
    port        = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "TCP"
    port        = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "cloudru_vpc_security_group" "postgres_security_group" {
  name       = "rooster-postgres-sg"
  network_id = cloudru_vpc_network.rooster_network.id

  ingress {
    protocol       = "TCP"
    port           = 5432
    security_group = [cloudru_vpc_security_group.vm_security_group.id]
  }
}

# ==================== Compute ====================

resource "cloudru_compute_image" "backend_image" {
  name = "rooster-backend-image"
  # Build from Dockerfile
  source_image_family = "ubuntu-2204-lts"
}

resource "cloudru_compute_instance" "backend_vm" {
  name          = var.vm_name
  platform_id   = var.vm_platform_id
  zone          = var.zone

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = cloudru_compute_image.backend_image.id
      size     = var.vm_disk_size
    }
  }

  network_interface {
    subnet_id  = cloudru_vpc_subnet.rooster_subnet.id
    security_group_ids = [cloudru_vpc_security_group.vm_security_group.id]
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# ==================== Database ====================

resource "cloudru_mdb_postgresql_cluster" "rooster_postgres" {
  name        = var.postgres_name
  environment = "PRODUCTION"

  resources {
    resource_preset {
      disk_size_gb       = var.postgres_disk_size
      memory_gb          = var.postgres_memory
      ncpus              = var.postgres_cores
    }
  }

  config {
    version = var.postgres_version
    charset = "utf8"
    lc_collate = "ru_RU.UTF-8"
  }

  host {
    zone          = var.zone
    subnet_id     = cloudru_vpc_subnet.rooster_subnet.id
    assign_public_ip = false
    security_group_ids = [cloudru_vpc_security_group.postgres_security_group.id]
  }

  database {
    name = "rooster"
  }

  user {
    name     = "rooster"
    password = var.postgres_password
    permission {
      database_name = "rooster"
    }
  }
}

# ==================== API Gateway ====================

resource "cloudru_apigateway_gateway" "rooster_gateway" {
  name = var.api_gateway_name

  domain {
    name = var.api_gateway_domain
  }

  spec = <<EOF
openapi: "3.0.0"
info:
  title: Rooster API
  version: "1.0.0"
paths:
  /tasks:
    get:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /tasks/{task_id}:
    get:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    put:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    delete:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /tasks/sync:
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /task-lists:
    get:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /task-lists/{list_id}:
    put:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    delete:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /task-lists/sync:
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /plans:
    get:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /plans/{plan_id}:
    put:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    delete:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /plans/sync:
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /material-stock:
    get:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    put:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /profile:
    get:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    put:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams:
    get:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams/{team_id}:
    put:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
    delete:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams/invite:
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams/accept-invitation:
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams/reject-invitation:
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams/invitations:
    delete:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams/{team_id}/invitations:
    get:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams/members/{member_user_id}/role:
    put:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams/members:
    delete:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /teams/leave:
    delete:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /storage/presigned-upload:
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
  /storage/presigned-download:
    post:
      x-backend-url: ${cloudru_compute_instance.backend_vm.internal_ipv4_address}:8000
EOF
}

# ==================== Outputs ====================

output "vm_internal_ip" {
  description = "VM internal IP address"
  value       = cloudru_compute_instance.backend_vm.internal_ipv4_address
}

output "vm_external_ip" {
  description = "VM external IP address"
  value       = cloudru_compute_instance.backend_vm.external_ipv4_address
}

output "postgres_host" {
  description = "PostgreSQL host"
  value       = cloudru_mdb_postgresql_cluster.rooster_postgres.host[0].fqdn
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "https://${var.api_gateway_domain}"
}

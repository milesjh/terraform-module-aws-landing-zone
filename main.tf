/*
Provisions the following resources:
- HCP Project
- HCP Group + Members
- TF Project
- TF Team + Members
- AWS Dynamic Provider Creds (via Vault?)
- TF Variable Set scoped to HCP Project
- - Default Tags
- - Dynamic Provider Config
- AzDO Repo
- TF Workspace for As-Code Configs
- Waypoint Templates

Required Variables:
- new_project_name
- environment
- team_name

Optional Variables:
- tf_org
- oauth_token_id

*/

terraform {
  required_providers {
    hcp = {
        source = "hashicorp/hcp"
        version = "~> 0.91"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.55"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
      version = "~> 1.1"
    }
    # doormat = {
    #     source = "doormat.hashicorp.services/hashicorp-security/doormat"
    #     version = ">= 0.0.3 "
    # }
  }
}

provider "tfe" {
    organization = "milesjh-sandbox"
}

provider "hcp" {
    project_id = "6392954d-18e4-46a6-a034-3f1bcef42459"
}

# provider "vault" {
#     address = data.tfe_outputs.hcp_clusters.values.vault_public_endpoint
#     token = data.tfe_outputs.hcp_clusters.values.vault_root_token
# }

resource "hcp_project" "main" {
    name        = var.new_project_name
    description = "AWS Landing Zone - ${var.new_project_name}"
}

resource "hcp_group" "main" {
    display_name = var.new_project_name
}

resource "hcp_project_iam_binding" "main" {
    project_id = hcp_project.main.resource_id
    principal_id = hcp_group.main.resource_id
    role = "roles/contributor"
}

resource "tfe_project" "main" {
    name = var.new_project_name
    description = "AWS Landing Zone - ${var.new_project_name}"
}

resource "tfe_team" "main" {
    name = var.new_project_name
    # sso_team_id = var.new_project_name
}

resource "tfe_team_project_access" "main" {
    access = "admin"
    team_id = tfe_team.main.id
    project_id = tfe_project.main.id
}

# data "tfe_outputs" "hcp_clusters" {
#     workspace = "2_hcp-clusters"
# }

# data "tfe_outputs" "vault_auth_config" {
#     workspace = "3_vault-auth-config"
# }

# resource "vault_jwt_auth_backend_role" "project_admin_role" {
#   role_name = "project_${tfe_project.main.name}_role"
#   backend   = data.tfe_outputs.vault_auth_config.values.jwt_auth_path

#   bound_audiences = ["vault.workload.identity"]
#   user_claim      = "terraform_full_workspace"
#   role_type       = "jwt"
#   token_ttl       = 300
#   token_policies  = ["admin"]

#   bound_claims = {
#     "sub" = join(":", [
#       "organization:${var.tf_org}",
#       "project:${tfe_project.main.name}",
#       "workspace:*",
#       "run_phase:*",
#     ])
#   }

#   bound_claims_type = "glob"
# }

data "hcp_vault_secrets_secret" "sandbox-creds" {
    for_each = zipmap(local.creds, local.creds)
    app_name = "sandbox-creds"
    secret_name = each.key
}

resource "tfe_variable_set" "project_vault_auth" {
  name        = "project_vault_auth_${tfe_project.main.name}"
  description = "Vault-backed Dynamic Provider Credentials"
  global      = false
}

resource "tfe_project_variable_set" "project_vault_auth" {
  variable_set_id = tfe_variable_set.project_vault_auth.id
  project_id      = tfe_project.main.id
}

resource "tfe_variable" "hvs_creds" {
  for_each     = zipmap(local.creds, local.creds)
  key          = each.key
  value        = data.hcp_vault_secrets_secret.sandbox-creds[each.key].secret_value
  category     = "env"
  sensitive    = true
  variable_set_id = tfe_variable_set.project_vault_auth.id
}

resource "tfe_variable_set" "project_default_tags" {
  name        = "project_default_tags_${tfe_project.main.name}"
  description = "Default Tags to be used by all modules created in this workspace"
  global      = false
}

resource "tfe_project_variable_set" "project_default_tags" {
  variable_set_id = tfe_variable_set.project_default_tags.id
  project_id      = tfe_project.main.id
}

locals {
    default_tags = {
        project = lower("${var.new_project_name}")
        team = lower("${var.team_name}")
        environment = lower("${var.environment}")
    }
    creds = [
        "ARM_CLIENT_ID",
        "ARM_CLIENT_SECRET",
        "ARM_SUBSCRIPTION_ID",
        "ARM_TENANT_ID",
        "AWS_ACCESS_KEY_ID",
        "AWS_SECRET_ACCESS_KEY",
        "HCP_CLIENT_ID",
        "HCP_CLIENT_SECRET",
        "HCP_PROJECT_ID"
    ]
}

resource "tfe_variable" "default_tags" {
  for_each     = local.default_tags
  key          = each.key
  value        = each.value
  category     = "terraform"
  sensitive    = false
  variable_set_id = tfe_variable_set.project_default_tags.id
}


// Create variables within the variable set
# resource "tfe_variable" "tfc_vault_provider_auth" {
#   key          = "TFC_VAULT_PROVIDER_AUTH"
#   value        = "true"
#   category     = "env"
#   variable_set_id = tfe_variable_set.project_vault_auth.id
# }

# resource "tfe_variable" "tfc_vault_addr" {
#   key          = "TFC_VAULT_ADDR"
#   value        = data.tfe_outputs.hcp_clusters.values.vault_public_endpoint
#   category     = "env"
#   variable_set_id = tfe_variable_set.project_vault_auth.id
# }

# resource "tfe_variable" "tfc_vault_namespace" {
#   key          = "TFC_VAULT_NAMESPACE"
#   value        = "admin"
#   category     = "env"
#   variable_set_id = tfe_variable_set.project_vault_auth.id
# }

# resource "tfe_variable" "tfc_vault_run_role" {
#   key          = "TFC_VAULT_RUN_ROLE"
#   value        = vault_jwt_auth_backend_role.project_admin_role.role_name
#   category     = "env"
#   variable_set_id = tfe_variable_set.project_vault_auth.id
# }

# resource "tfe_variable" "tfc_vault_auth_path" {
#   key          = "TFC_VAULT_AUTH_PATH"
#   value        = vault_jwt_auth_backend.tfc.path
#   category     = "env"
#   variable_set_id = tfe_variable_set.project_vault_auth.id
# }

# resource "tfe_variable" "vault_addr" {
#   key          = "VAULT_ADDR"
#   value        = data.tfe_outputs.hcp_clusters.values.vault_public_endpoint
#   category     = "env"
#   variable_set_id = tfe_variable_set.project_vault_auth.id
# }

# resource "tfe_variable" "vault_namespace" {
#   key          = "VAULT_NAMESPACE"
#   value        = "admin"
#   category     = "env"
#   variable_set_id = tfe_variable_set.project_vault_auth.id
# }

# resource "tfe_variable" "vault_auth_method" {
#   key          = "auth_method"
#   value        = "dynamic_creds"
#   category     = "terraform"
#   variable_set_id = tfe_variable_set.project_vault_auth.id
# }


data "azuredevops_project" "main" {
  name = "hcp-demo-june24"
}

resource "azuredevops_git_repository" "main" {
  project_id = data.azuredevops_project.main.project_id
  name       = "${var.new_project_name}-infra"
  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_git_repository_file" "tfc_config" {
  repository_id       = azuredevops_git_repository.main.id
  file                = "cloud.tf"
  content    = <<-EOT

  terraform {
    cloud {
      organization = "${var.tf_org}"

      workspaces {
        tags = ["${var.new_project_name}"]
      }
    }
  }

  EOT
  #branch              = "refs/heads/master"
  commit_message      = "First commit"
  overwrite_on_create = true
}

resource "time_sleep" "wait35s" {
  depends_on = [
    azuredevops_git_repository_file.tfc_config
  ]

  create_duration = "35s"
}

resource "tfe_workspace" "main" {
  name              = "${var.new_project_name}"
  organization      = var.tf_org
  auto_apply        = true
  queue_all_runs    = true
  terraform_version = "~> 1.8.0"
  tag_names         = [lower(var.new_project_name), lower(var.environment), lower(var.team_name), "azdo"]

  vcs_repo {
    # branch = "refs/heads/master"
    identifier     = "milesjh365-sandbox/hcp-demo-june24/_git/${azuredevops_git_repository.main.name}"
    oauth_token_id = var.oauth_token_id
  }

  depends_on = [time_sleep.wait35s]
}

# resource "tfe_run_trigger" "main" {
#   for_each = local.env

#   workspace_id  = tfe_workspace.main[each.key].id
#   sourceable_id = tfe_workspace.main[each.value].id
# }

# resource "tfe_team_access" "main-dev" {
#   access       = "plan"
#   team_id      = var.tfe_team_developers_id
#   workspace_id = tfe_workspace.main.id
# }

# resource "tfe_team_access" "main-ops" {
#   access       = "write"
#   team_id      = var.tfe_team_ops_id
#   workspace_id = tfe_workspace.main.id
# }

resource "tfe_variable" "name" {
  key          = "name"
  value        = var.new_project_name
  category     = "terraform"
  workspace_id = tfe_workspace.main.id
}
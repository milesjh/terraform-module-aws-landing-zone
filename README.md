# Terraform Module: AWS Landing Zone
This No-code module will provision all resources needed for establishing a secure landing zone in AWS. 
Consumption Patterns: HCP Waypoint, HCP Terraform, Service Now, or the Kubernetes Operator

## Input Variables
### Required Inputs
These variables must be set in the module block when using this module.

environment
- string
- Description: (no description specified)

new_project_name
- string
- Description: (no description specified)

team_name
- string
- Description: (no description specified)

### Optional Inputs
These variables have default values and don't have to be set to use this module. You may set these variables to override their default values.
oauth_token_id
- string
- Description: (no description specified)
- Default: "ot-2cRFS6YD1VV4TzKn"

tf_org
- string
- Description: (no description specified)
- Default: "milesjh-sandbox"

## Resources
This is the list of resources that the module may create. The module can create zero or more of each of these resources depending on the count value. The count value is determined at runtime. The goal of this page is to present the types of resources that may be created.

This list contains all the resources this plus any submodules may create. When using this module, it may create less resources if you use a submodule.

This module defines 17 resources.

- azuredevops_git_repository.main
- azuredevops_git_repository_file.tfc_config
- hcp_group.main
- hcp_project.main
- hcp_project_iam_binding.main
- tfe_project.main
- tfe_project_variable_set.project_default_tags
- tfe_project_variable_set.project_vault_auth
- tfe_team.main
- tfe_team_project_access.main
- tfe_variable.default_tags
- tfe_variable.hvs_creds
- tfe_variable.name
- tfe_variable_set.project_default_tags
- tfe_variable_set.project_vault_auth
- tfe_workspace.main
- time_sleep.wait35s
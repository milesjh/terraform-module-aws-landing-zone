

# WARNING: Generated module tests should be considered experimental and be reviewed by the module author.

variables {
  new_project_name = "test_project"
  team_name = "test_team"
  environment = "test_env"
  tf_org = "test_org"
  oauth_token_id = "test_token"
}

run "hcp_project_validation" {
  assert {
    condition     = hcp_project.main.name == "test_project"
    error_message = "incorrect project name"
  }
  assert {
    condition     = hcp_project.main.description == "AWS Landing Zone - test_project"
    error_message = "incorrect project description"
  }
}

run "hcp_group_validation" {
  assert {
    condition     = hcp_group.main.display_name == "test_project"
    error_message = "incorrect group display name"
  }
}

run "hcp_project_iam_binding_validation" {
  assert {
    condition     = hcp_project_iam_binding.main.project_id == hcp_project.main.resource_id
    error_message = "incorrect project id"
  }
  assert {
    condition     = hcp_project_iam_binding.main.principal_id == hcp_group.main.resource_id
    error_message = "incorrect principal id"
  }
  assert {
    condition     = hcp_project_iam_binding.main.role == "roles/contributor"
    error_message = "incorrect role"
  }
}

run "tfe_project_validation" {
  assert {
    condition     = tfe_project.main.name == "test_project"
    error_message = "incorrect project name"
  }
  assert {
    condition     = tfe_project.main.description == "AWS Landing Zone - test_project"
    error_message = "incorrect project description"
  }
}

run "tfe_team_validation" {
  assert {
    condition     = tfe_team.main.name == "test_project"
    error_message = "incorrect team name"
  }
}

run "tfe_team_project_access_validation" {
  assert {
    condition     = tfe_team_project_access.main.access == "admin"
    error_message = "incorrect access"
  }
  assert {
    condition     = tfe_team_project_access.main.team_id == tfe_team.main.id
    error_message = "incorrect team id"
  }
  assert {
    condition     = tfe_team_project_access.main.project_id == tfe_project.main.id
    error_message = "incorrect project id"
  }
}

run "tfe_workspace_validation" {
  assert {
    condition     = tfe_workspace.main.name == "test_project"
    error_message = "incorrect workspace name"
  }
  assert {
    condition     = tfe_workspace.main.organization == "test_org"
    error_message = "incorrect organization"
  }
  assert {
    condition     = tfe_workspace.main.auto_apply == true
    error_message = "incorrect auto apply"
  }
  assert {
    condition     = tfe_workspace.main.queue_all_runs == true
    error_message = "incorrect queue all runs"
  }
  assert {
    condition     = tfe_workspace.main.terraform_version == "~> 1.8.0"
    error_message = "incorrect terraform version"
  }
  assert {
    condition     = contains(tfe_workspace.main.tag_names, "test_project")
    error_message = "incorrect tag names"
  }
  assert {
    condition     = contains(tfe_workspace.main.tag_names, "test_env")
    error_message = "incorrect tag names"
  }
  assert {
    condition     = contains(tfe_workspace.main.tag_names, "test_team")
    error_message = "incorrect tag names"
  }
  assert {
    condition     = contains(tfe_workspace.main.tag_names, "azdo")
    error_message = "incorrect tag names"
  }
}

run "tfe_variable_validation" {
  assert {
    condition     = tfe_variable.name.key == "name"
    error_message = "incorrect variable key"
  }
  assert {
    condition     = tfe_variable.name.value == "test_project"
    error_message = "incorrect variable value"
  }
  assert {
    condition     = tfe_variable.name.category == "terraform"
    error_message = "incorrect variable category"
  }
  assert {
    condition     = tfe_variable.name.workspace_id == tfe_workspace.main.id
    error_message = "incorrect workspace id"
  }
}
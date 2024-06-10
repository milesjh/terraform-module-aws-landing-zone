

# WARNING: Generated module tests should be considered experimental and be reviewed by the module author.

variables {
  new_project_name = "test_project"
  team_name = "test_team"
  environment = "test_env"
  tf_org = "test_org"
  oauth_token_id = "test_token"
}

run "variables_validation" {
  assert {
    condition     = var.new_project_name == "test_project"
    error_message = "incorrect new_project_name"
  }
  assert {
    condition     = var.team_name == "test_team"
    error_message = "incorrect team_name"
  }
  assert {
    condition     = var.environment == "test_env"
    error_message = "incorrect environment"
  }
  assert {
    condition     = var.tf_org == "test_org"
    error_message = "incorrect tf_org"
  }
  assert {
    condition     = var.oauth_token_id == "test_token"
    error_message = "incorrect oauth_token_id"
  }
}
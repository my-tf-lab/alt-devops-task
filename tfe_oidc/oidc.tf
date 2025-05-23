data "aws_iam_openid_connect_provider" "app_terraform_io" {
  url = "https://app.terraform.io"
}

resource "aws_iam_role" "terraform_deploy_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "app.terraform.io:aud" = var.audience
            }
            StringLike = {
              "app.terraform.io:sub" = "organization:${var.organization_name}:project:${var.project_name}:workspace:${var.workspace_name}:run_phase:*"
            }
          }
          Effect = "Allow"
          Principal = {
            Federated = data.aws_iam_openid_connect_provider.app_terraform_io.arn
          }
        },
      ]
      Version = "2008-10-17"
    }
  )
  name                  = "terraform-cloud-oidc-access-deployment-role-2"
  description           = null
  force_detach_policies = false
  managed_policy_arns   = []

}

resource "aws_iam_role_policy_attachment" "this_policy-attach" {
  role       = aws_iam_role.terraform_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

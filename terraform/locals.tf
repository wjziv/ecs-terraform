# NOTE: it is assumed:
# - these are already created
# - the developer is authenticated on aws cli to use this user.
locals {
  aws_account_id  = var.aws_account_id
  aws_devops_user = "arn:aws:iam::${local.aws_account_id}:user/${var.aws_devops_user_name}"
  root_user       = "arn:aws:iam::${local.aws_account_id}:root"
}

locals {
  roles = {
    kms_prod_key_access_role = {
      name = "KMS_PROD_KEY_ACCESS_ROLE"
      tags = {env = "prod"}
      managed_policy_arns = []
      policy = file("./policies/role-policy.json")
      assume_role_policy = templatefile(
        "./policies/assume-role-policy.tpl",
        {aws_root_user = local.root_user}
      )
    }
    kms_qa_key_access_role = {
      name = "KMS_QA_KEY_ACCESS_ROLE"
      tags = {env = "qa"}
      managed_policy_arns = []
      policy = file("./policies/role-policy.json")
      assume_role_policy = templatefile(
        "./policies/assume-role-policy.tpl",
        {aws_root_user = local.root_user}
      )
    }
    kms_dev_key_access_role = {
      name = "KMS_DEV_KEY_ACCESS_ROLE"
      tags = {env = "dev"}
      managed_policy_arns = []
      policy = file("./policies/role-policy.json")
      assume_role_policy = templatefile(
        "./policies/assume-role-policy.tpl",
        {aws_root_user = local.root_user}
      )
    }
    kms_admin_key_access_role = {
      name = "KMS_ADMIN_ROLE"
      tags = {env = "all"}
      managed_policy_arns = []
      policy = file("./policies/key-admin-policy.json")
      assume_role_policy = templatefile(
        "./policies/assume-role-policy.tpl",
        {aws_root_user = local.root_user}
      )
    }
  }
}

locals {
  users = {
    developer_user_1 = {
      name   = "developer_user_1"
      policy = file("./policies/user-policy.json")
      tags   = {}
      groups = [
          aws_iam_group.group["devs_env_dev"].name,
          aws_iam_group.group["devs_env_qa"].name,
          aws_iam_group.group["devs_env_prod"].name
      ]
    }
    developer_user_2 = {
      name   = "developer_user_2"
      policy = file("./policies/user-policy.json")
      tags   = {}
      groups = [
          aws_iam_group.group["devs_env_dev"].name,
          aws_iam_group.group["devs_env_qa"].name
      ]
    }
    key_admin = {
      name   = "key_admin_user"
      policy = file("./policies/key-admin-policy.json")
      tags   = {}
      groups = [
          aws_iam_group.group["admins"].name
      ]
    }
  }
}

locals {
  groups = {
    devs_env_dev = {
      name = "developers_env_dev"
      policy = templatefile(
        "./policies/group-policy.tpl",
        {desired_role = aws_iam_role.role["kms_dev_key_access_role"].arn}
      )
    }
    devs_env_qa = {
      name = "developers_env_qa"
      policy = templatefile(
        "./policies/group-policy.tpl",
        {desired_role = aws_iam_role.role["kms_qa_key_access_role"].arn}
      )
    }
    devs_env_prod = {
      name = "developers_env_prod"
      policy = templatefile(
        "./policies/group-policy.tpl",
        {desired_role = aws_iam_role.role["kms_prod_key_access_role"].arn}
      )
    }
    admins = {
      name = "admins"
      policy = templatefile(
        "./policies/group-policy.tpl",
        {desired_role = aws_iam_role.role["kms_admin_key_access_role"].arn}
      )
    }
  }
}

locals {
  keys = {
    prod = {
      description             = "Key for prod env using SOPS"
      deletion_window_in_days = 10
      policy                  = templatefile(
        "./policies/key-policy.tpl",
        {
          key_benutz_identities = [aws_iam_role.role["kms_prod_key_access_role"].arn],
          key_administration_identities = [aws_iam_role.role["kms_admin_key_access_role"].arn, local.aws_devops_user]
        }
      )
      enable_key_rotation     = true
      tags = {
        use = "example"
        env = "prod"
      }
    }
    qa = {
      description             = "Key for qa env using SOPS"
      deletion_window_in_days = 10
      policy                  = templatefile(
        "./policies/key-policy.tpl",
        {
          key_benutz_identities = [aws_iam_role.role["kms_qa_key_access_role"].arn],
          key_administration_identities = [aws_iam_role.role["kms_admin_key_access_role"].arn, local.aws_devops_user]
        }
      )
      enable_key_rotation     = true
      tags = {
        use = "example"
        env = "qa"
      }
    }
    dev = {
      description             = "Key for dev env using SOPS"
      deletion_window_in_days = 10
      policy                  = templatefile(
        "./policies/key-policy.tpl",
        {
          key_benutz_identities = [aws_iam_role.role["kms_dev_key_access_role"].arn],
          key_administration_identities = [aws_iam_role.role["kms_admin_key_access_role"].arn, local.aws_devops_user]
        }
      )
      enable_key_rotation     = true
      tags = {
        use = "example"
        env = "dev"
      }
    }
  }
}

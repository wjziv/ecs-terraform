resource "aws_iam_user" "user" {
  for_each = local.users
  name     = each.value.name
  tags     = each.value.tags
}

resource "aws_iam_access_key" "access_key" {
  for_each   = local.users
  user       = aws_iam_user.user[each.key].name
}

resource "aws_iam_user_policy" "policy" {
  for_each = local.users
  name     = "${each.value.name}-policy"
  user     = aws_iam_user.user[each.key].name
  policy   = each.value.policy
}

resource "aws_kms_key" "sops_key" {
  for_each                = local.keys
  description             = each.value.description
  deletion_window_in_days = each.value.deletion_window_in_days
  policy                  = each.value.policy
  enable_key_rotation     = each.value.enable_key_rotation
  tags                    = each.value.tags
}

resource "aws_iam_role" "role" {
  for_each = local.roles
  name     = each.value.name
  assume_role_policy = each.value.assume_role_policy
  tags = each.value.tags
}

resource "aws_iam_role_policy" "policy" {
  for_each = local.roles
  name     = "${each.value.name}-policy"
  role     = each.value.name
  policy   = each.value.policy
}

resource "aws_iam_group" "group" {
  for_each  = local.groups
  name      = each.value.name
}

resource "aws_iam_group_policy" "policy" {
  for_each  = local.groups
  name      = "${each.value.name}-policy"
  group     = aws_iam_group.group[each.key].name
  policy    = each.value.policy
}

resource "aws_iam_user_group_membership" "user_group_membership" {
  for_each  = local.users
  user      = each.value.name
  groups    = each.value.groups
}

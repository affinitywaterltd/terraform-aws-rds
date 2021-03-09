resource "aws_iam_role" "this_admin" {
  count   = try(lookup(var.admin_role_config, "enabled"), false) ? 1 : 0
  name    = "rds_admin_role_${var.identifier}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {

      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ${jsonencode(try(lookup(var.admin_role_config, "princpial"), []))}
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "this_admin" {
  count  = try(lookup(var.admin_role_config, "enabled"), false) ? 1 : 0
  name   = "rds_admin_policy_${var.identifier}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
         "Sid": "rdsAdminPermissions",
         "Action": [
           "rds:*"
         ],
         "Effect": "Allow",
         "Resource": [
           "${module.db_instance.this_db_instance_arn}"
         ]
       }
     ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this_admin" {
  count  = try(lookup(var.admin_role_config, "enabled"), false) ? 1 : 0
  role       = aws_iam_role.this_admin.0.name
  policy_arn = aws_iam_policy.this_admin.0.arn
}
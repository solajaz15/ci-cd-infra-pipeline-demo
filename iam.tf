
resource "aws_iam_role" "ssm_fleet_ec2" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "jenkins-role"
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.ssm_fleet_ec2.name
}


#IAM policy
resource "aws_iam_policy" "policy" {
  name        = format("%s_%s", var.component_name, "fleet_managerpolicy")
  description = "Access  policy of ec2 to ssm fleet"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
         "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
     ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ssm_fleet_ec2.name
  policy_arn = aws_iam_policy.policy.arn
}
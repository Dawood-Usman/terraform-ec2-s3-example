# Create IAM role for EC2 to access S3
resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.project_name}-ec2-s3-role-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy for S3 access
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "${var.project_name}-ec2-s3-policy-${terraform.workspace}"
  role = aws_iam_role.ec2_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.s3_bucket.bucket_arn,
          "${module.s3_bucket.bucket_arn}/*"
        ]
      }
    ]
  })
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile-${terraform.workspace}"
  role = aws_iam_role.ec2_s3_role.name
}

# S3 Module
module "s3_bucket" {
  source = "./modules/s3"

  bucket_name  = "${var.s3_bucket_name}-${terraform.workspace}"
  project_name = var.project_name
  environment  = terraform.workspace
}

# EC2 Module
module "ec2_instance" {
  source = "./modules/ec2"

  instance_type         = var.instance_type
  ami_id                = var.ami_id
  key_name              = var.key_name
  project_name          = var.project_name
  environment           = terraform.workspace
  instance_profile_name = aws_iam_instance_profile.ec2_profile.name
  allowed_ssh_cidr      = var.allowed_ssh_cidr
}

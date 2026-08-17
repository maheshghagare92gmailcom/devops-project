# ################################################################################
# # KMS Key for EFS
# ################################################################################

# resource "aws_kms_key" "efs" {
#   description         = "${local.name} EFS encryption key"
#   enable_key_rotation = true

#   tags = {
#     Name        = "${local.name}-efs-kms"
#     Environment = var.environment_name
#     Component   = "EFS"
#   }
# }

# ################################################################################
# # KMS Alias
# ################################################################################

# resource "aws_kms_alias" "efs" {
#   name          = "alias/${local.name}-efs"
#   target_key_id = aws_kms_key.efs.key_id
# }

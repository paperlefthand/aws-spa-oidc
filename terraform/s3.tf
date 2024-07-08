# resource "aws_s3_bucket" "bucket" {
#   bucket        = "spa-oidc"
#   force_destroy = true
# }


# resource "aws_s3_bucket_policy" "policy" {
#   bucket = aws_s3_bucket.bucket.id
#   policy = {
#     "Version" : "2008-10-17",
#     "Id" : "PolicyForCloudFrontPrivateContent",
#     "Statement" : [
#       {
#         "Sid" : "AllowCloudFrontServicePrincipal",
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "cloudfront.amazonaws.com"
#         },
#         "Action" : "s3:GetObject",
#         "Resource" : "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*",
#         "Condition" : {
#           "StringEquals" : {
#             "AWS:SourceArn" : "arn:aws:cloudfront::533267243448:distribution/E3V777U769NAKU"
#           }
#         }
#       }
#     ]
#   }
# }


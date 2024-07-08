# resource "aws_cloudfront_distribution" "distribution" {
#   default_root_object = "index.html"
#   enabled             = true
#   http_version        = "http2"
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   staging             = false
#   wait_for_deployment = true
#   # web_acl_id
#   default_cache_behavior {
#     allowed_methods = ["GET", "HEAD", "OPTIONS"]
#     #   cache_policy_id
#   }
#   origin {
#     domain_name = 
#   }
# }

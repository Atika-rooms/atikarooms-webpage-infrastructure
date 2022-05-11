aws_default_tags = {
  Billing           = "AR Marketing Dept"
  Project           = "Static Website"
  Environment       = "Testing"
  Terraform-Managed = true
}

bucket_name     = "atika-rooms-website-testing"
bucket_name_tag = "Atika Rooms Website"

root_domain = "atikarooms.com"
web_domains = ["testing.atikarooms.com"]
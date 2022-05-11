aws_default_tags = {
  Billing           = "AR Marketing Dept"
  Project           = "Static Website"
  Environment       = "Production"
  Terraform-Managed = true
}

bucket_name     = "atika-rooms-website-production"
bucket_name_tag = "Atika Rooms Website"

root_domain = "atikarooms.com"
web_domains = ["atikarooms.com", "www.atikarooms.com"]
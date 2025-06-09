resource "aws_ssm_parameter" "hosted_zone_cert_arn" {
  name  = "/roboshop/hosted_zone_cert_arn"
  type  = "String"
  value = aws_acm_certificate.hosted_zone_cert.arn

}

data "aws_s3_bucket" "buildbucket5" {
  bucket = "buildbucket5"
}

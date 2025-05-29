resource "aws_acm_certificate" "hosted_zone_cert" {
  validation_method = "DNS"
  domain_name       = "balaji.website"

  subject_alternative_names = [
    "*.balaji.website"
  ]
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "hosted_zone_cert_validation_records" {

  for_each = {
    for dvo in aws_acm_certificate.hosted_zone_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = "Z04307862A5Z0E82KA5RX"
}

resource "aws_acm_certificate_validation" "hosted_zone_cert_validation" {
  certificate_arn         = aws_acm_certificate.hosted_zone_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.hosted_zone_cert_validation_records : record.fqdn]
}

resource "aws_route53_record" "cloud_resume_s3_hosting_record" {
  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "balaji.website"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloud_resume_s3_hosting_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloud_resume_s3_hosting_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}



######



resource "aws_cloudfront_distribution" "cloud_resume_s3_hosting_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.buildbucket5.website_endpoint
    origin_id   = "Cloud-Resume-S3-StaticWebsiteOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "resume.html"
  aliases             = ["balaji.website"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "Cloud-Resume-S3-StaticWebsiteOrigin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.hosted_zone_cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "Cloud-Resume-CDN"
  }
}




#####



resource "aws_dynamodb_table" "cloud_resume_dynamodb_table" {
  name         = "cloud_resume_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"

  attribute {
    name = "Id"
    type = "S"
  }
}



#####



resource "aws_iam_role" "cloud_resume_lambda_exec_role" {
  name = "cloud-resume-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "cloud_resume_lambda_dynamodb_policy" {
  name        = "cloud-resume-lambda-dynamodb-policy"
  description = "Allow Lambda to read/write DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ]
      Resource = aws_dynamodb_table.cloud_resume_dynamodb_table.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloud_resume_lambda_exec_attach" {
  role       = aws_iam_role.cloud_resume_lambda_exec_role.name
  policy_arn = aws_iam_policy.cloud_resume_lambda_dynamodb_policy.arn
}



#####



resource "aws_lambda_function" "cloud_resume_visit_counter_lambda" {
  function_name = "cloud-resume-visit-counter"
  role          = aws_iam_role.cloud_resume_lambda_exec_role.arn
  handler       = "lambda_function_code.lambda_handler"
  runtime       = "python3.13"

  filename         = "../lambda_function_code.zip"
  source_code_hash = filebase64sha256("../lambda_function_code.zip")

  environment {
    variables = {
      ALLOWED_ORIGIN = "https://balaji.website"
    }
  }

  tags = {
    Name = "cloud-resume-visit-counter-lambda-function"
  }
}

resource "aws_lambda_function_url" "cloud_resume_lambda_url" {
  function_name      = aws_lambda_function.cloud_resume_visit_counter_lambda.function_name
  authorization_type = "NONE"
}

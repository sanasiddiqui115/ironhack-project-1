data "aws_route53_zone" "root" {
  name         = var.root_domain
  private_zone = false
}

resource "aws_route53_record" "vote_a" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "vote.${var.root_domain}"
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "vote_aaaa" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "vote.${var.root_domain}"
  type    = "AAAA"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "result_a" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "result.${var.root_domain}"
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "result_aaaa" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "result.${var.root_domain}"
  type    = "AAAA"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

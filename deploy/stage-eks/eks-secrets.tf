provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
################################################################
resource "kubernetes_secret_v1" "rds_db" {
  metadata {
    name      = "db-creds"
    namespace = var.env
  }

  data = {
    DATABASE_HOST     = module.aurora_eks_app_postgres.this_rds_cluster_endpoint
    DATABASE_USER     = "root"
    DATABASE_PASSWORD = data.aws_ssm_parameter.fanclash_app_postgres_passwd.value
  }
  type = "kubernetes.io/Opaque"
}

resource "kubernetes_secret_v1" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = var.env
  }

  data = {
    RMQ_USER     = data.aws_ssm_parameter.rabbitmq_user.value
    RMQ_PASSWORD = data.aws_ssm_parameter.rabbitmq_passwd.value
    RMQ_ERLANG   = data.aws_ssm_parameter.rabbitmq_erlang_cookie.value
  }
  type = "kubernetes.io/Opaque"
}

resource "kubernetes_secret_v1" "fcm_creds" {
  metadata {
    name      = "fcm-creds"
    namespace = var.env
  }

  data = {
    FCM_CREDENTIALS = base64decode("ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOiAiZmFuY2xhc2gtc3RhZ2luZyIsCiAgInByaXZhdGVfa2V5X2lkIjogIjU3ODEzOGVjNzE0NWYzMTI4NTU4OWI4ZWRjYjJlYTA1NGE5OGEyYWUiLAogICJwcml2YXRlX2tleSI6ICItLS0tLUJFR0lOIFBSSVZBVEUgS0VZLS0tLS1cbk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRQ3F2MzUxcXZ2T3lnVGdcbm1WdWl3VDhTQnlYWkVCcmJJMEZiZ0M3TXY0aElEdWJoc0poK0tzczFBWmoxYXNqUGIvSUpoOUNuVzVtakxLTldcbjRtdCtROXZ4aU1ZbVRPaXdNelEvZzViUjFkcWJ2alRqQjBPRWwza2Q2RFArVUYyTHNtamFjT3F2NmJmN01VUjJcbitPTUk2T3hjd0QxdHVwYm9EcGw1T0xHRFJuT1dwN2ZqeHVTbEcvRTUrUDN5SnNwbGJ5WlZ2WVJ1dTlFTUptcXlcbm1qOTVmckM0QWNib3lEMzlnTTVSbC9WQUtNQXpqelkvdWEybWMzQzg2WlFKc3hxcWpmVWRTT1dYaFp0ZDdnSUlcbkltOWRlOEZCTGhDcnp0d3craUJhajFGUERZYW1KbzVoOGowZ3ROY1B6WVcwN0xNalV2TGMyMGtJVkxFcFArSDZcbmRIYnIzQVNuQWdNQkFBRUNnZ0VBQzJPdG1FUzQrakN3aFpqRks0U1BZL0QxSGRiOHE1eGM2akVSTGhnaWk0ZnVcbjc2UDdjQU1EdmZ2bXk0djliQlRRQk1HNThjZmk1aWIrbURlUEt3TjB3dFk0UFdySTVLUHR1c1RZeFJOcU94UkRcbmE5ZGFzaGYyZkwrMTVDTlJNaFhLOTdNcmZHTnZJY0xHQ2RlTk1WVjBHclc2QXowOGZxc21vcGJkQkdBcEtxWFdcbkxsRlFCcnpPT3AyeXl5TDVvY0Z1dXJ4bXBCck9TVU9rRmVVcjI4dHQzekFNeXppRWZyRG4wa0J2d3BVY1dGVjBcbkF5MDF6clBxTFg0SDVrNExxMEFuZTJTZ0RIWVJtT0cyNzZMSGVSaEYwZmhDM3hXYkF2ajBPQnBJdTNlbWRKMExcbm5PS2psUG0rWkZYL2Q1ci95SXJRb2k0ZThuenBlbEJrUHcva05lWEVoUUtCZ1FEd0JjNXowZmFIdUNaSmFJOElcbkdSYlovNHNrNU1rcS96ZzVya2JmcURQVCtpR0pVZzhPeDRYNGI1c0lEcWJ4QlE0SlVBbHVveUt6QlpScTdHRmNcbmxKQ2Jiallxa0psRzFSVmlBSHZrTlJvZFlvMDZPNFNXM0pRME9pU3NMVklvSFhPZFVIdEpKa0pySjRKZXpJbHJcbm5kcUlqTkFrZDNyNWh5dUdaS0U1NzM0TnN3S0JnUUMySFRBR1BaZEJ4eW5vZGluLzY1a2dVWElZVElVMFNwbDlcbjJOUTVJOUZIbEdQVUdyT3lRaXFYWTRvV1k5a1IwOVdoTTZvM0hMOUlQM21mQ1hoazk4RFFVM0t2dUQxSm5hVjdcbmpoZ2xVOHBEdWpMUGdoZ1VDOEZMdVcvSFlCTytGeDZmVWlqemwwaXMyTmNCNjV4VERqUngzZ29Vem5jTE4wV0xcbnFxb3pQMnU3UFFLQmdRQ2pDUTZuRldPRDVNMzg1d3pnejBuNllkNDkvVG0zL3d4T0FkY2FiTUpucG12SlB2Z0RcbmJmdk9PT0R4cENJNWJObVA4ZEcyV1JGazBORnpuNFN5d2lkSHJLRVdZSW44MXhoakxUajZWaWVhOWlvLzk5V2tcbk04aG5nV2NQbk9sRlhsdjk2NEVTdXU0Nm91ZW5SUC9ESGNJbkpwN3JaazBkMlhiekhyOTAvdng4aVFLQmdFUGtcblBiTVY0djJ5c2Z6bmtHRElCQjM0UHdDd0JqaW9WdkNEbFJwNEw5enZoUWZkcklBWUNxakZnd1UxMUFiQllqTG1cbmY5NXI2U09XQmxFenhwNWRmcFFyaCtYYVdYN0lOcGtKTUJjNlZYMUtQUWIvQ05yd1J1OWtBamZocVhxRVEvWkJcbk91TVUweE1kQTRyRHUxTjdTREhyQlBjY3dXUjlCb0E2NzVpTFhDNUJBb0dBRHZpcjg5L3k0ZzNPNkRPMU1nVlZcbnNtM3RhcWxON1V0UFA0dWxTT1FZaEhEbGFkN21oajAwYXdRTGZnYVppZDc0QWFHQ0V1akgrYTFqMW5PdTVpNUZcbkpieHZTeDdPU0JCUm5Yd2xHbjg3M3hheWlWaVV3WUNEdHNaUCtUTmNWZFNjQ0U0WjdxTzV0OUdGbG1GMFpoUGZcbjB6OWhzYjY4c3BnRnVBelg5OFd1NTFRPVxuLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLVxuIiwKICAiY2xpZW50X2VtYWlsIjogImZpcmViYXNlLWFkbWluc2RrLWllN3JnQGZhbmNsYXNoLXN0YWdpbmcuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICJjbGllbnRfaWQiOiAiMTA4ODg4MzYzNzI3Nzg1Mjg1OTQzIiwKICAiYXV0aF91cmkiOiAiaHR0cHM6Ly9hY2NvdW50cy5nb29nbGUuY29tL28vb2F1dGgyL2F1dGgiLAogICJ0b2tlbl91cmkiOiAiaHR0cHM6Ly9vYXV0aDIuZ29vZ2xlYXBpcy5jb20vdG9rZW4iLAogICJhdXRoX3Byb3ZpZGVyX3g1MDlfY2VydF91cmwiOiAiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vb2F1dGgyL3YxL2NlcnRzIiwKICAiY2xpZW50X3g1MDlfY2VydF91cmwiOiAiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vcm9ib3QvdjEvbWV0YWRhdGEveDUwOS9maXJlYmFzZS1hZG1pbnNkay1pZTdyZyU0MGZhbmNsYXNoLXN0YWdpbmcuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iCn0K")
  }
  type = "kubernetes.io/Opaque"
}

resource "kubernetes_secret_v1" "ortec_creds" {
  metadata {
    name      = "ortec-creds"
    namespace = var.env
  }

  data = {
    ORTEC_USERNAME = data.aws_ssm_parameter.ortec_user.value
    ORTEC_PASSWORD = data.aws_ssm_parameter.ortec_paswd.value
  }
  type = "kubernetes.io/Opaque"
}

resource "kubernetes_secret_v1" "gce_opta_feed_creds" {
  metadata {
    name      = "gce-opta-feed-creds"
    namespace = var.env
  }

  data = {
    credentials = base64decode("ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOiAidWZsLTIwIiwKICAicHJpdmF0ZV9rZXlfaWQiOiAiODQwYTg3NWEwOGVmZDM3YTFlMjdlMDFmMTVjNjhiM2VjMzk0N2QxOSIsCiAgInByaXZhdGVfa2V5IjogIi0tLS0tQkVHSU4gUFJJVkFURSBLRVktLS0tLVxuTUlJRXZnSUJBREFOQmdrcWhraUc5dzBCQVFFRkFBU0NCS2d3Z2dTa0FnRUFBb0lCQVFDbzJhbzdhenVDdzMzdVxuUjA0clVjU1BKcUVEV0x6Z1lZVUtoS2JDcGlPR21nNS81aTEydjFyaEJIK0M2eE1ndnB0Y1BIVXNrMjY5Lys5Wlxuc3NEdThDejd5RlVLYy9OcTZqbWxkWlBxemFFV3FVeG5NVTluVS9QVnVKaVUwejN2S005dmhrZXRqN2dPQTZxalxuWjdKcCtnS2ZQYkxDTGhySi9Ua2w5NmJDaXBLVWRqRmVHVXR1VjNmamoxZ0t6S3AxUy9ZNVRGQ2gzallFWDdheFxuT3lPV05VcXNsd2VUQlJHQ1FXK0Q1ZjRpMUJMVk1QMnQ3UWhhenplTmtwOVhVbWVkRnB3Q2ZBTHg3SjR1LzRpT1xuRlJkLzlNTDgxR2xqdFk5QzE0UkNaRzBlN2dQNkhxdkxqelVOdGswZWZZOHJXeGhHbDU0SStWS2tqNTA1bXl0S1xuRUFMTVF6ZlJBZ01CQUFFQ2dnRUFCUitsdjJ2VTZ5RGlLZ3JXaW1YNWRadm5JdUl4eVFxWExqeUc1WktEc3NxVlxuOUxlWUJaUnZrNGhwYU1ydFVsUmhBOVFwMGhKMGpTWVRyZXNlQTZJY3hmOGhrQ2I0bEo2Z09vUnVML1Vtd0RpZVxuN1pBSGZYYUVzdnJlVm1zYWpxNmZBaDZzVk0zdStJTTZvdjY3TnBBSmt2OXlTZHQ2OWZUTnpuaDNWNkU3Z0JtOFxuRjNQdmNBZ0tKNGxSbUYvS3JlbjFrTEdJaE1KRDhaMWI5aFp3NGMwWWhRbEUvV2hHOWVaNHNxY0MvdzlqUERMbFxuNkJ6OHNZVWNzVW9VUzRmZDdxYmViS1FPZlBnaitNYkNJWnBSNXJsTlBiSnZWQXVodW5QV3NHR2lFazY5MDFnOVxuUWZjL05RTTdLeXllRVRLVTBGQzVUdHpPY0sySi9FdFZJVzVFUk8xdXFRS0JnUURXVTNZbEtMcGJrNVUvMmovQ1xuQmx4aVo0Wm1oMFBaRTd1TWQ4c1VhYU1aRTcxcnZLRnpBMWxGRjFpdHNERzFRL21wZTBHQWhUWnlEMkgrRnRyL1xuSnBvdk1STG5lWndEKzAwK2hqUGdRNitwa0JrWDc0UXlmL2R1SUVBV3FDaGtjVTlEbTB1M0hJeUpJVGFwQ24wSVxuWmhsSFRMWWViUnJmcmdmdDhxajJjbHgrVHdLQmdRREpyb3lpek83SmR4ZTZiYVdvOXZhdWd0bHBRRU5BWUtQS1xuV1dXTTNtUnBHdnJSVFVJRUswNU14MkwyN2J4cXFrSWc2MU1lUy9lVEpxUHdiWUE3RlZJbUttM3dnNC9tNUhvTFxuMmRLRXhKRjd1elpzVnVQN2JsQWJGU1JIaWZvS3RrbEhkdi80K1ZodG1rVEQ2UUJOZDBDWTNxbFZVdFhOaDNVd1xuNHBnQkNuaC8zd0tCZ1FDRTlzNXJDek5pTU5MOUJCZGQ5YmhHekZjVE1JT2xIcHJSOEZlcTJFWjQva2dibUxESVxudTZFY1BmbWo5NVUvRVdiSUFGR0l2QndrOHVvbVNtT2V1NElZR09mVGR4eVZVOGgrSzUvdlY4Nlk4VzYvN0xZa1xuNWtMSXJYVlZHUW5HRm8zSU1ZWHRtZWFPQkc3MnZDMEprdDNINEExMEh0ZjNRTzVtYm83b0pkYS8vUUtCZ0VhR1xuTUExNXhnSlREOHdVTFhxaEtXK3F0K1hUSC9FeUdmUlhRR2g3Ri9lZEJKb04vd2pBTC9ndlBNOEdJUDNYblpvdlxuVC9obkxpS1p2M2dDZ25XbXBmeE1sL2NqdWoxT0pkTmhEdmw0Vnp0Q0l1ek5rWmxKWU4rbmkvRXNNWEJ2Zjc1cVxud1dYSm8zOW9FNlhDSTJYelRuWm1YaVpFK2hpTnhwQWFuSGE0dDV4WEFvR0JBS3BxUDJteXBzT1lyZDd6VWZ0Z1xuTmROeUJMNm1uV2k5bjcyOXpjTStWcjd2OGp5RWtBNWVhd3NQTG1RODNaUjY5MjcvbUZmeXZyNmppZDNXWUN0VlxuREFkYU5GWHV3Vk9MckZ5N2RXYnJCUWQrbkxtd25IWlJYbEtvdGRMYkZVdmIyMCtQSnBybXBGbG83SC8ydW9ZOVxud05YaWRxK1NDWGw2K1hHQlZNSkdsUFQwXG4tLS0tLUVORCBQUklWQVRFIEtFWS0tLS0tXG4iLAogICJjbGllbnRfZW1haWwiOiAiZmVlZC11cGxvYWRlckB1ZmwtMjAuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICJjbGllbnRfaWQiOiAiMTA5OTAwOTkyNjIyNTgwMzI2MDM4IiwKICAiYXV0aF91cmkiOiAiaHR0cHM6Ly9hY2NvdW50cy5nb29nbGUuY29tL28vb2F1dGgyL2F1dGgiLAogICJ0b2tlbl91cmkiOiAiaHR0cHM6Ly9vYXV0aDIuZ29vZ2xlYXBpcy5jb20vdG9rZW4iLAogICJhdXRoX3Byb3ZpZGVyX3g1MDlfY2VydF91cmwiOiAiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vb2F1dGgyL3YxL2NlcnRzIiwKICAiY2xpZW50X3g1MDlfY2VydF91cmwiOiAiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vcm9ib3QvdjEvbWV0YWRhdGEveDUwOS9mZWVkLXVwbG9hZGVyJTQwdWZsLTIwLmlhbS5nc2VydmljZWFjY291bnQuY29tIgp9Cg==")
  }
  type = "kubernetes.io/Opaque"
}


# K8S Config
########################################################
resource "kubernetes_config_map_v1" "fanclash_config" {
  metadata {
    name      = "fanclash-config"
    namespace = var.env
  }

  data = {
    AMQP_MATCH_EVENTS_EXCHANGE  = "match_event"
    AMQP_GAMES_EXCHANGE         = "games"
    AMQP_SYSTEM_EXCHANGE        = "system"
    STATSD_HOST                 = "telegraf.monitoring.svc"
    DATABASE_NAME               = "fanclash"
    GCE_PLAYER_IMAGES_BUCKET    = "ufl-player-images"
    GCE_TEAM_CRESTS_BUCKET      = "ufl-team-crests"
    GCE_USER_AVATAR_BUCKET      = "fanclash-user-avatars"
    GCE_OPTA_FEED_BUCKET        = "ufl-opta-feeds"
  }
}

resource "kubernetes_config_map_v1" "mobile_api_config" {
  metadata {
    name      = "mobile-api-config"
    namespace = var.env
  }

  data = {
    DJANGO_SETTINGS_MODULE  = "mobile_api.settings.staging"
    DATABASE_HOST           = module.aurora_eks_app_postgres.this_rds_cluster_endpoint
    BROKER_URL              = "amqp://${data.aws_ssm_parameter.rabbitmq_user.value}:${data.aws_ssm_parameter.rabbitmq_passwd.value}@rabbitmq-0.rabbitmq-headless.rabbitmq.svc.cluster.local:5672/ufl"
    RMQ_HOST                = "rabbitmq-0.rabbitmq-headless.rabbitmq.svc.cluster.local"
    RMQ_PORT                = "5672"
    RMQ_VHOST               = "ufl"
    RMQ_USER                = data.aws_ssm_parameter.rabbitmq_user.value
    REVENUE_CAT_API_KEY     = data.aws_ssm_parameter.revenue_cat_api_key.value
  }
}



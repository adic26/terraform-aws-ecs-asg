[
  {
    "memory": 800,
    "logConfiguration": {
      "logDriver": "syslog",
      "options": {
        "syslog-address": "udp://logs6.papertrailapp.com:13812",
        "tag": "{{.Name}}"
      }
    },
    "environment": [{
        "name": "APP_DEBUG",
        "value": "1"
      },
      {
        "name": "APP_ENV",
        "value": "sit"
      },
      {
        "name": "APP_KEY",
        "value": "${opsvr_app_key}"
      },
      {
        "name": "APP_LOG",
        "value": "syslog"
      },
      {
        "name": "AUDIT_DEBUG",
        "value": "0"
      },
      {
        "name": "AUDIT_DIRECT_DB_WRITES",
        "value": "0"
      },
      {
        "name": "AUDIT_KINESIS_REGION",
        "value": "us-east-1"
      },
      {
        "name": "AUDIT_KINESIS_VERSION",
        "value": "2013-12-02"
      },
      {
        "name": "AUDIT_SHARD_BUCKETS",
        "value": "5"
      },
      {
        "name": "AUDIT_STATE",
        "value": "0"
      },
      {
        "name": "ES_DSN1",
        "value": "http://172.31.3.106:9200"
      },
      {
        "name": "ES_DSN2",
        "value": ""
      },
      {
        "name": "INTERNAL_AUTH_APP",
        "value": ""
      },
      {
        "name": "INTERNAL_AUTH_KEY",
        "value": ""
      },
      {
        "name": "INTERNAL_AUTH_SIG",
        "value": ""
      },
      {
        "name": "LEGACY_DB_HOST",
        "value": ""
      },
      {
        "name": "LEGACY_DB_NAME",
        "value": ""
      },
      {
        "name": "LEGACY_DB_PASS",
        "value": ""
      },
      {
        "name": "LEGACY_DB_USER",
        "value": ""
      },
      {
        "name": "MAIL_HOST",
        "value": "smtp.mailtrap.io"
      },
      {
        "name": "MAIL_PASSWORD",
        "value": "${mailtrap_password}"
      },
      {
        "name": "MAIL_PORT",
        "value": "2525"
      },
      {
        "name": "MAIL_USERNAME",
        "value": "${mailtrap_username}"
      },
      {
        "name": "MANDRILL_SECRET",
        "value": ""
      },
      {
        "name": "MONGO_AUDIT_DB_NAME",
        "value": "audit-trail"
      },
      {
        "name": "MONGO_AUDIT_DSN",
        "value": "${mongo_audit_dsn}"
      },
      {
        "name": "MONGO_DB_NAME",
        "value": "sit-opsserver"
      },
      {
        "name": "MONGO_DSN",
        "value": "${mongo_dsn}"
      },
      {
        "name": "NEWRELIC_APP",
        "value": "Ops Server [sit]"
      },
      {
        "name": "QUEUE_DRIVER",
        "value": "mongodb"
      },
      {
        "name": "QUEUE_ENV",
        "value": "sit"
      },
      {
        "name": "REDIS_DSN",
        "value": "tcp://172.31.3.106:6379"
      },
      {
        "name": "SYSLOG_HOST",
        "value": "logs6.papertrailapp.com"
      },
      {
        "name": "SYSLOG_PORT",
        "value": "22002"
      }
    ],
    "portMappings": [{
      "hostPort": 8088,
      "protocol": "tcp",
      "containerPort": 8088
    }],
    "image": "${opsvr_image}",
    "name": "web"
  }
]

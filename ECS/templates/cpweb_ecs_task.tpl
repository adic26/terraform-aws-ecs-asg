[
  {
    "memory": 512,
    "logConfiguration": {
      "logDriver": "syslog",
      "options": {
        "syslog-address": "udp://logs.papertrailapp.com:30791",
        "tag": "{{.Name}}"
      }
    },
    "environment": [
      {
        "name": "NODE_ENV",
        "value": "sit"
      },
      {
        "name": "API_URL",
        "value": "${opsvr_url}"
      },
      {
        "name": "API_KEY",
        "value": "${cpweb_apikey}"
      },
      {
        "name": "APP_ID",
        "value": "WEB"
      }
    ],
    "portMappings": [{
      "hostPort": 7777,
      "protocol": "tcp",
      "containerPort": 7777
    }],
    "image": "${cpweb_image}",
    "name": "node"
  }
]

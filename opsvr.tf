/*
*  Create ECS Task Definition - Backend Services
*/
# Simply specify the family to find the latest ACTIVE revision in that family.
data "template_file" "opsvrweb" {
  template = "${file("${path.module}/templates/opsvr_ecs_task.tpl")}"

  vars {
    opsvr_app_key = "${var.opsvr_app_key}"
    mailtrap_password = "${var.mailtrap_password}"
    mailtrap_username = "${var.mailtrap_username}"
    mongo_audit_dsn = "${var.mongo_audit_dsn}"
    mongo_dsn = "${var.mongo_dsn}"
    opsvr_image = "${var.opsvr_image}"
  }
}

data "aws_ecs_task_definition" "opsvrweb" {
  task_definition = "${aws_ecs_task_definition.opsvrweb.family}"
}

resource "aws_ecs_task_definition" "opsvrweb" {
  family = "opsvr-${var.cluster_name}-web"
  container_definitions = "${data.template_file.opsvrweb.rendered}"
}

resource "aws_ecs_service" "opsvrweb" {
  name          = "opsvr-${var.cluster_name}-web"
  cluster       = "${aws_ecs_cluster.ecs_cluster.id}"
  desired_count = 2

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.opsvrweb.family}:${max("${aws_ecs_task_definition.opsvrweb.revision}", "${data.aws_ecs_task_definition.opsvrweb.revision}")}"

  load_balancer {
    elb_name = "opsvr-${var.cluster_name}-elb"
    container_name = "web"
    container_port = "8088"
  }

  depends_on = [
    "aws_elb.opsvr"
  ]
}

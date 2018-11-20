data "template_file" "opsvr_workers" {
  template = "${file("${path.module}/templates/workers-ecs-task.tpl")}"

  vars {
    cluster_name      = "${var.cluster_name}"
    fam_worker_type   = "${var.fam_worker_type}"
    queue_worker_type = "${var.queue_worker_type}"
    opsvr_app_key     = "${var.opsvr_app_key}"
    mailtrap_password = "${var.mailtrap_password}"
    mailtrap_username = "${var.mailtrap_username}"
    mongo_audit_dsn   = "${var.mongo_audit_dsn}"
    mongo_dsn         = "${var.mongo_dsn}"
    opsvr_image       = "${var.opsvr_image}"
  }
}

resource "aws_ecs_task_definition" "opsvr_workers" {
  family                = "opsvr-${var.cluster_name}-${var.fam_worker_type}"
  container_definitions = "${data.template_file.opsvr_workers.rendered}"
}

resource "aws_ecs_service" "opsvr_workers" {
  name            = "opsvr-${var.cluster_name}-worker-general-${var.worker_type}"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.opsvr_workers.arn}"
  desired_count   = 1

  depends_on = [
    "aws_ecs_task_definition.opsvr_workers",
  ]

  # Track the latest ACTIVE revision
  # task_definition = "${aws_ecs_task_definition.opsvr_workers.family}:${max("${aws_ecs_task_definition.opsvr_workers.revision}", "${data.aws_ecs_task_definition.opsvr_workers.revision}")}"
}

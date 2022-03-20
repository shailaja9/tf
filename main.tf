resource "aws_security_group" "rds-security-group" {
  name        = "${var.project.name}-nonprod-rds-sg"
  description = "${var.project.name}-nonprod-rds-sg"
  vpc_id      = var.aws.vpc_id
  tags        = var.default_tags
}

resource "aws_rds_cluster" "primary_cluster" {
  cluster_identifier      = "${var.project.name}-nonprod-rds-cluster"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = "13.4"
  vpc_security_group_ids  = ["${aws_security_group.rds-security-group.id}"]
  db_subnet_group_name    = "nonprod-db-subnet-group"
  availability_zones      = ["ap-south-1a"]
  database_name           = "${var.project.name}nonprod"
  master_username         = var.postgres.username
  master_password         = var.postgres.password
  backup_retention_period = 7
  preferred_backup_window = "01:00-02:00"
  port                    = 5433
  storage_encrypted       = true
  kms_key_id              = "arn:aws:kms:ap-south-1:423085655527:key/13ee0d52-9a3d-4d07-a45a-718ec6af4337"
  tags                    = var.default_tags
  deletion_protection     = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count               = 1
  identifier          = "${var.project.name}-nonprod-rds-cluster-${count.index}"
  cluster_identifier  = aws_rds_cluster.primary_cluster.id
  instance_class      = "db.r5.large"
  engine              = aws_rds_cluster.primary_cluster.engine
  engine_version      = aws_rds_cluster.primary_cluster.engine_version
  publicly_accessible = false

  tags = var.default_tags
}


output "aws_rds_cluster" {
  value     = aws_rds_cluster.primary_cluster
  sensitive = true
}

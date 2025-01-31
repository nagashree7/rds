# Set provider configuration for AWS
provider "aws" {
  region = "us-east-1"  # You can change this to your desired region
}

# Create a security group to allow access to the database
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds_sg_"

  ingress {
    from_port   = 3306         # MySQL default port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow connections from anywhere (adjust this in production for better security)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
  }
}

# Create the RDS MySQL instance
resource "aws_db_instance" "mydb" {
  identifier        = "mydb-instance"
  engine            = "mysql"
  engine_version    = "8.0"  # You can change to any supported version
  instance_class    = "db.t3.micro"  # Adjust the instance class size as needed
  allocated_storage = 20  # 20 GB of storage
  storage_type      = "gp2"  # General Purpose SSD storage
  db_name           = "mydatabase"
  username          = "admin"  # Root username for MySQL
  password          = "admin"  # Change to a secure password
  parameter_group_name = "default.mysql8.0"  # Use the appropriate parameter group
  multi_az          = false  # Set to true for high availability in production
  publicly_accessible = true  # Set to false for internal access only
  skip_final_snapshot = true  # Set to true for no snapshot at deletion (careful in production)

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  tags = {
    Name = "MySQL Database Instance"
  }

  # Optional: Enabling automatic backups
  backup_retention_period = 7  # Retain backups for 7 days
  preferred_backup_window  = "07:00-09:00"  # Set backup window (optional)

  # Optional: Enabling monitoring
  monitoring_interval = 60  # In seconds, set to 60 for 1-minute monitoring
}

output "db_endpoint" {
  value = aws_db_instance.mydb.endpoint
  description = "The endpoint of the MySQL database instance"
}

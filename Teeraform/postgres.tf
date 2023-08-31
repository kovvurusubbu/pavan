provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet_a" {
  count      = 2
  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.main.id
}

resource "aws_security_group" "rds" {
  name_prefix = "rds-sg-"

  vpc_id = aws_vpc.main.id

  // Define inbound and outbound rules as needed
}

resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = aws_subnet.subnet_a[*].id
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"  # Use an instance class that is compatible
  identifier           = "my-postgres-db"
  username             = "postgres"
  password             = "yourpassword"
  parameter_group_name = "default.postgres13"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  skip_final_snapshot = true

  tags = {
    Name = "MyPostgresDB"
  }
}

resource "aws_iam_role" "rds_iam_role" {
  name = "rds-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_iam_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  role       = aws_iam_role.rds_iam_role.name
}

resource "aws_db_instance_role_association" "example" {
  db_instance_identifier = aws_db_instance.postgres.identifier
  feature_name           = "s3Import"
  role_arn               = aws_iam_role.rds_iam_role.arn
}


-------------------------------------------------------------------------------
provider "aws" {
  region     = "ap-south-1"
  access_key = ""
  secret_key = ""
}

/*resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet_a" {
  count      = 2
  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.main.id
}

resource "aws_security_group" "rds" {
  name_prefix = "rds-sg-"

  vpc_id = aws_vpc.main.id

  // Define inbound and outbound rules as needed
}

resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = aws_subnet.subnet_a[*].id
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"  # Use an instance class that is compatible
  identifier           = "my-postgres-db"
  username             = "postgres"
  password             = "yourpassword"
  parameter_group_name = "default.postgres13"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  skip_final_snapshot = true

  tags = {
    Name = "MyPostgresDB"
  }
}

resource "aws_iam_role" "rds_iam_role" {
  name = "rds-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_iam_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  role       = aws_iam_role.rds_iam_role.name
}

resource "aws_db_instance_role_association" "example" {
  db_instance_identifier = aws_db_instance.postgres.identifier
  feature_name           = "s3Import"
  role_arn               = aws_iam_role.rds_iam_role.arn
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
} */
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet_a" {
  count             = 3 # Creating subnets in 3 Availability Zones
  cidr_block        = "10.0.${count.index + 1}.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-south-1${element(["a", "b", "c"], count.index)}"
}

resource "aws_security_group" "rds" {
  name_prefix = "rds-sg-"

  vpc_id = aws_vpc.main.id

  // Define inbound and outbound rules as needed
}

resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = aws_subnet.subnet_a[*].id
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"
  identifier           = "my-postgres-db"
  username             = "postgres"
  password             = "yourpassword"
  parameter_group_name = "default.postgres13"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  skip_final_snapshot = true

  tags = {
    Name = "MyPostgresDB"
  }
}

resource "aws_iam_role" "rds_iam_role" {
  name = "rds-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_iam_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  role       = aws_iam_role.rds_iam_role.name
}


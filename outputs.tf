# outputs.tf

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.jenkins.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_instance.jenkins.public_ip}:${var.jenkins_port}"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.jenkinsbucket.bucket
}

# Jenkins status

This directory is reserved for a tested CI/CD pipeline. No executable Jenkins pipeline is implemented yet.

The intended workflow validates and runs Ansible, then performs Terraform plan/apply under approved change control. Keep all credentials in Jenkins Credentials or a connected secrets manager.

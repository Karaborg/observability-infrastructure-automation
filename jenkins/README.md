# Jenkins status

This directory is reserved for CI/CD orchestration. No executable Jenkins pipeline is implemented yet.

The intended pipeline will validate and run the Ansible deployment, then run Terraform plan/apply for central Grafana resources once that configuration exists. Store credentials in Jenkins Credentials or a connected secrets manager, never in a Jenkinsfile.

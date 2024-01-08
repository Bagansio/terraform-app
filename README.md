## Terraform app

This project provides a Terraform configuration to deploy a Cloud Functions service to manage Compute Engine (CE) instances. It also includes two subrepos: http-status and CF-manage-CE.

### Subrepo: http-status

The `http-status` subrepo contains a simple HTTP server that will respond with a 200 OK status code. This server can be used to verify that the Cloud Functions service is running correctly.

### Subrepo: CF-manage-CE

The `CF-manage-CE` subrepo contains the source code for the Cloud Functions service that is used to manage Compute Engine instances. This service can be triggered by Cloud Events to start, stop, or reboot CE instances.

To deploy this project, will need a Google Cloud Platform (GCP) project with the following APIs enabled:

* Cloud Resource Manager API
* Eventarc API
* Compute Engine API
* Cloud Functions API
* VPC Access API
* IAM API

Also creates a service account with the following roles:

* roles/iam.serviceAccountUser
* roles/compute.instanceAdmin
* roles/cloudfunctions.serviceAgent

### Deployment

To deploy the project, follow these steps:

1. Clone the repository
2. Initialize Terraform
3. Set the following Terraform variables:
    * `project_id`: Your GCP project ID
    * `region`: The region where you want to deploy the resources
    * `instance_name`: The name of the Compute Engine instance that you want to manage
    * `instance_zone`: The zone where the Compute Engine instance is located
4. Apply the Terraform configuration

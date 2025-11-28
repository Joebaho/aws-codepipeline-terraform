# 🚀 AWS Codepipeline using Terraform for Deployment

This project demonstrates first how to **provision infrastructure on AWS using Terraform**. Second use **AWS codepipeline** to automate the process of building the infrastructure and deploy a web page that will be accessible throught a load balancer. It’s a hands-on DevOps project showing Infrastructure as Code (IaC) and automation via a CI/CD tool.

---

## 📂 Project Structure

   ```

├── main.tf      # Terraform configuration for AWS resources 
├── providers.tf # AWS provider configuration
├── variables.tf  # Define all input and changable arguments
├── terraform.tfvars  # Value of all differents variables
├── outputs.tf      # List of all output that can be use 
├── codepipeliine.tf     # Configuration of the CI/CD pipeline
├── buildspec-app.yml   # Deployment script for the application  
├── buildspec-infra.yml   # Deployment script for the infrastructure
├── Application/
         ├── scripts
                ├── after_install.sh 
                ├── application_start.sh
                ├── application_stop.sh
                ├── before_install.sh
         ├── templates
                ├── index.html
         ├── appspec-infra.yml 
├── user-data/
         ├── app-server.sh
   ```     

---

## ⚡ Features

* 🌍 Infrastructure provisioning with **Terraform**
* ☁️ Automated deployment on **AWS**
* 📜 Build of three statges automation process with **AWS Codepipeline**
* 🛠️ Demonstrates **Infrastructure as Code (IaC)** best practices
* 📌 Simplify the deployment via **AWS CI/CD tools** and **Github**

---

## 🛠️ Prerequisites

Make sure you have:

* ✅ [Terraform](https://developer.hashicorp.com/terraform/downloads) installed
* ✅ AWS CLI configured (`aws configure`) with proper credentials
* ✅ Bash shell (Linux/Mac/WSL)
* ✅ Understand the concept and process of CI/CD deployment with AWS Codepipeline

---

## 🚀 How to Run

1.**Clone this repository**

   ```bash
   git clone https://github.com/Joebaho/aws-codepipeline-terraform.git
   cd aws-codepipeline-terraform
   ```

2.**Initialize the folder**

   ```bash
   terraform init
   ```

The process will display following images:

Terraform init: 
![Terraform init](images/init.png)

3.**Check for syntax error and validate the configuration**

   ```bash
   terraform fmt
   terraform validate
   ```

Terraform fmt and validate:
![Terraform validate](images/validate.png)

4.**Overview the numbers and resources that will be create**

   ```bash
   terraform plan
   ```

Terraform plan:
![Terraformy plan](images/plan.png)

5.**Provision the resources by applying the plan**

   ```bash
   terraform apply -auto-approve
   ```

Terraform apply:
![Terraform apply](images/apply.png)

6.**Check all resources outpts**

   ```bash
   terraform output
   ```

Terraform output:
![Terraform output](images/outputs.png)

After copy the ELb dns in the output section you can go paste that in a new window on the browser and the web page will display.

![Web Page](images/webpage.png)

Go in the console > Codepileline to see how the pipeline stages are running 

![CodePipeline1](images/CodePipeline1.png)

![CodePipeline2](images/CodePipeline2.png)

![CodePipeline3](images/CodePipeline3.png)

![CodePipeline4](images/CodePipeline4.png)

![CodePipeline5](images/CodePipeline5.png)

7.**Destroy Infrastructure (when done)**

  ```bash
  terraform destroy -auto-approve
  ```

After typing or pasting the command you will get images

![Terraformy destroy 1](images/destroy1.png)
![Terraform destroy 2](images/destroy2.png)

---

## 📌 Learning Outcomes

* Understand **Terraform basics** (providers, resources, state management)
* Automate deployments with **AWS Codepileline**
* Hands-on AWS infrastructure provisioning and automatic deployment 

---

## 🔗 Resources

* [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [Terraform CLI Docs](https://developer.hashicorp.com/terraform/cli)

---
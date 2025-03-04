# Fantastic App IaC demo

## AWS EKS, Aurora and Helm Infrastructure Deployment

This project provisions a **highly available and secure AWS infrastructure** using **Terraform**. The architecture integrates **Amazon EKS** for container orchestration and **Amazon Aurora PostgreSQL Serverless v2** as the primary database solution. It uses Helm to deploy an small demo application to read and write the PostgreSQL database. The code is modular and reusable, making it easy to deploy and maintain infrastructure across multiple environments by using *.auto.tfvars along with Terraform workspaces

---

## Getting Started
### Prerequisites
- **Terraform**: Version 1.0.0 or later.
- **AWS CLI**: Configured with appropriate credentials.
- AWS account with permissions to create the necessary resources.
- An instance of Consul Vault running and set ENV vars like:
  - export VAULT_ADDR="http://127.0.0.1:8200"
  - export VAULT_TOKEN="your token" 
- Set database credentials in Vault:
  - vault kv put kv/fantastic-app-iac-demo/dev/aurora-db adminUser="superadmin" adminPassword="supersecret"  
- Set env variable on Terraform workstation: 
  - export TF_VAR_aws_account_id="your account id" 
- Terraform uses .auto.tfvars files to automatically load values for different environments like Dev, Prod, etc basen on terraform workspace 
- Create and use Terraform Workspace
  - terraform workspace new dev
  - terraform workspace select dev
- Set Terraform Remote Backend with AWS. 
  - the terraform-backend-CloudFormation.yml file creates the backend in AWS
  - aws cloudformation create-stack --stack-name TerraformBackend --template-body file://terraform-backend-CloudFormation.yml --capabilities CAPABILITY_NAMED_IAM


---

##  Architecture Overview

### **Networking & Security**
- **VPC with Private and Public Subnets**  
  - `10.0.0.0/16` CIDR allocated using `cidrsubnet()`  
  - Private subnets for database and internal services  
  - Public subnets for ALB (if required)
  - NAT Gateways are used to allow resources in private subnets to access the internet. They are in the Public Subnets and they have routes to the internet via an Internet Gateway (IGW).
  - Traffic Flow:
    - Resources in private subnets send outbound traffic to the NAT Gateway by route table entry that routes 0.0.0.0/0 to the NAT Gateway.
    - The NAT Gateway forwards this traffic to the internet via the IGW by route table entry that routes 0.0.0.0/0 (all internet traffic) to the IGW.

- **Security Groups & Access Control**
  - EKS automatically manages node security groups, retrieved dynamically  
  - Aurora security group allows inbound traffic only from **EKS worker nodes** 
  - Aurora DB is only accesible in private subnets via VPC endpoints.
  - Private subnets CIDRs dynamically calculated and assigned to Aurora SG 
  - EKS API whitelist access
  - Sensitive data, like DB credentials, is stored on Consul Vault
  - TLS termination with ALB for Kubernetes deployment
  - Credentials are stored in Vault for Terraform and then in Kubernetes Secret Opaque.
  - Sentive data is treated with special care to avoid exposing it in logs, console output, or the Terraform state file.
  - Worker nodes deployed with `aws_eks_node_group` in private subnets
  - Automatic security group assignment  
  - IAM roles for service accounts (`IRSA`) for least-privilege access 
  - Encrypted at rest using **KMS keys**
  - Encrypted in transit using **TLS**
  - Encrypted Terraform backend stored in AWS
  - IAM Authentication enabled on Production environment (prod.auto.tfvars)   
  - IAM OpenID Connect (OIDC) for EKS administration enabled.

### **High Availability & Resilience**
- **Aurora PostgreSQL Serverless v2** 
  - Serverles automatically adjusts database capacity based on workload demands to ensure stability and cost efficiency  
  - Aurora storage automatically grows as your data grows, up to 128 TB.
  - PostgreSQL ensures the scalability, availability, and durability
  - "aurora-iopt1" storage type on Production
  - Terraform Use Multi-AZ deployments for Aurora.
  - Aurora uses distributed subnets across multiple Availability Zones (AZs).
  - At least **one writer & one reader instance**
  - Scales automatically based on demand  

- **Performance Insights & Monitoring**
  - `performance_insights_enabled = true` is enabled on Prod
  - Retains **database insights** for better observability  

- **EKS**
  - Deployed across multiple **Availability Zones**  
  - Auto-healing nodes via Kubernetes  
  - It uses multiple NAT Gateways (one per AZ) instead of a single NAT to prevent failures.
  - Load balance incoming traffic to ensure even distribution.
  - Container image is build with multi-layer caching to reduce container startup
  - EKS node group has autoscaling enabled
  - HPA Kubernetes resource is deployed for the Deployment(deployed with Helm)

## **Architecture Decisions: EKS + Aurora + Helm**

### **Terraform?**

1. **Managing Multiple Environments**

   - **Workspaces** allow you to easily manage multiple environments (e.g., `dev`, `staging`, `prod`) in the same Terraform configuration without needing separate codebases. Each workspace acts like a separate instance of your Terraform configuration, allowing you to manage environment-specific state, resources, and variables in an isolated way.
  
   - **`auto.tfvars`** files automatically load variables based on the workspace, which means you can have different variable configurations for different environments without manually specifying them every time. For example:
     - `dev.auto.tfvars` for development-specific variables.
     - `prod.auto.tfvars` for production-specific variables.

2. **Simplified Configuration Management**

   - With **workspaces**, you don't need to manually pass variable files when switching between environments. Terraform will automatically use the correct `auto.tfvars` file based on the active workspace.

   - You can automate deployment and management across various environments with minimal changes to your configuration. This eliminates the need to manage separate state files, improving overall management and reducing the risk of misconfigurations.
  
   - **Example Workflow:**
     1. You run `terraform workspace select dev`.
     2. Terraform automatically loads the variables from `dev.auto.tfvars`.
     3. You apply the changes for the development environment.


### **Why Amazon EKS?**

1. **Managed Kubernetes Service**
   - **EKS** provides a **fully managed** Kubernetes environment, offloading the complexity of managing the control plane, worker nodes, and integrations. 
   - This choice allows us to focus on deploying applications and services, while AWS handle critical Kubernetes components, such as **high availability**, **scalability**, and **security patches**. 
   - EKS integrates seamlessly with other AWS services, ensuring **strong interoperability** and **native AWS support**, which is vital for the success of the deployment.

2. **Scalability and Auto-Healing**
   - EKS allows **horizontal scaling** with **auto-scaling groups** for worker nodes and Kubernetes resources, ensuring that the infrastructure can handle increased traffic or resource usage efficiently. 
   - Kubernetes' **self-healing capabilities** automatically replaces unhealthy pods or nodes, ensuring minimal downtime.

3. **Security**
   - EKS offers strong security features, like  IAM roles for service accounts, allowing fine-grained access control to AWS resources directly from Kubernetes.
   - **EKS node security groups** ensures that only trusted network traffic can reach the nodes, preventing unauthorized access.
   - Kubernetes RBAC (Role-Based Access Control) provide an extra layer of access control for users and workloads, ensuring proper privileges for different teams or services.

4. **Integration with AWS Services**
   - Integration with **CloudWatch**, **CloudTrail**, and **AWS X-Ray** for monitoring and logging allows deep insights into the health and performance of the Kubernetes cluster and applications running on it.
   - **AWS IAM** and **AWS Secrets Manager** are used to securely manage sensitive data, ensuring that credentials and environment variables are protected.

---

### **Why Aurora PostgreSQL?**

1. **Fully Managed Relational Database**
   - **Aurora** provides a **fully managed relational database** that is compatible with **PostgreSQL** and **MySQL**. It offers the benefits of high availability, durability, and scalability without the overhead of managing database instances.
   - **Aurora Serverless v2** was chosen for its ability to **automatically scale** based on demand, making it cost-effective during periods of low activity, while scaling to meet higher demand as needed.

2. **High Availability and Durability**
   - Aurora is designed for **high availability**, with **automatic failover** across multiple Availability Zones (AZs) to ensure that the database remains operational, even in the case of AZ failures.
   - Aurora’s storage layer automatically **replicates data** to multiple Availability Zones, ensuring **data durability** and resilience.

3. **Performance Insights and Monitoring**
   - The **Performance Insights** and **Enhanced Monitoring** features of Aurora helps track and diagnose database performance. This is essential for optimizing the database to meet performance goals and handling large amounts of transactional data effectively.

4. **Security**
   - Aurora provides **encryption at rest** using **AWS KMS** keys and **encryption in transit** using **TLS**, ensuring that sensitive data is secured both during transmission and storage.
   - **IAM-based authentication** simplifies credential management, eliminating the need for hard-coded credentials in your application.

---

### **Why Helm for Kubernetes Resource Deployment?**

1. **Declarative and Reproducible Deployments**
   - **Helm** is the de facto package manager for Kubernetes resources, they can be defined in **charts**, making them **reusable** and **consistent** across different environments.
   - Helm charts encapsulate all dependencies and configurations needed for a given application, ensuring that the deployment process is **consistent**, **scalable**, and **reproducible**.

2. **Flexibility and Customization**
   - Helm charts allow for **parameterization** and **templating**. They can be easily configured as chart to work with different parameters for **different environments** or application versions. 
   - Custom **values files** provide flexibility in setting environment-specific configurations.

---

## Security Best Practices Implemented
✔ **Least Privilege Access** via IAM  
✔ **Security Groups Restrict Ingress & Egress**  
✔ **VPC Private Subnets for Database & Compute**  
✔ **KMS Encryption for RDS Data & Secrets**  
✔ **CloudWatch Monitoring & Alerting**  

---

## Terraform Implementation

### **Modules Used**
- **`modules/vpc`** → VPC, subnets, security groups  
- **`modules/eks`** → EKS cluster, managed node groups  
- **`modules/aurora`** → Aurora PostgreSQL cluster  
- **`modules/helm`** → Application and Database deployment using Kubernetes resouces   

## Future Enhancements

- Add Service Mesh (e.g., Istio or App Mesh) for microservices observability
- Use AWS WAF + Shield to protect the public-facing app from attacks.
- Replace debug python run with Gunicorn as WSGI server in the demo application.
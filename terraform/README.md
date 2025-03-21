### Part 1: Deploy Both Flask and Express on a Single EC2 Instance Using Terraform

The goal of this setup is to deploy both Flask (Python backend) and Express (Node.js frontend) applications on a single EC2 instance, using Terraform for provisioning the instance and a script to manage the installation and startup of the applications.

---

### Step-by-Step Deployment Process

#### 1. **Terraform Setup**

First, we will create the necessary Terraform configuration files to provision an EC2 instance and set up the Flask and Express applications.

**Files needed:**

- `main.tf`
- `variables.tf`
- `output.tf`

#### 2. **Create `variables.tf`**

Define variables for better control over the instance details like instance type, region, and key pair.



#### 3. **Create `main.tf`**

This file will contain the main configuration for provisioning the EC2 instance and using a user-data script to install Flask and Express and configure the environment.


#### 4. **Create `output.tf`**

This file will output the public IP address of the EC2 instance so you can access the Flask and Express applications.


#### 5. **Deploying with Terraform**

Once the Terraform files are created, follow these steps to deploy:

1. **Initialize Terraform**: Run the following command to initialize Terraform and download necessary provider plugins.

   ```bash
   terraform init
   ```

2. **Plan the deployment**: Run the following command to preview the resources that will be created.

   ```bash
   terraform plan
   ```

3. **Apply the configuration**: Run the following command to provision the EC2 instance and run the setup script.

   ```bash
   terraform apply
   ```

   Type "yes" when prompted.

4. **Check the Outputs**: After the deployment is complete, Terraform will output the public IP of the instance.

---

### 6. **Access the Applications**

Once the EC2 instance is up and running, you can access the Flask and Express applications via the instance's public IP.

- Flask app: `http://<public-ip>:5000`
- Express app: `http://<public-ip>:3000`

Both applications should be running and accessible via their respective ports.

---

### Notes:
- Ensure that the security group allows incoming traffic on ports `5000` and `3000`.
- You can use an SSH key to access the EC2 instance for further troubleshooting or manual changes if needed.

This concludes the documentation for deploying both Flask and Express on a single EC2 instance using Terraform.
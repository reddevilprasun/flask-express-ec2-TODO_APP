### Part 2: Deploy Flask and Express on Separate EC2 Instances Using Terraform

In this process, we'll deploy the Flask backend and Express frontend on two separate EC2 instances using Terraform, while ensuring proper network configuration for communication between the instances and public access.

---

### Step-by-Step Deployment Process

#### 1. **Plan Infrastructure and Networking**

To deploy Flask and Express on separate EC2 instances, we need to provision:
- Two EC2 instances: one for Flask and one for Express.
- A VPC (Virtual Private Cloud) to ensure both instances are on the same network and can communicate securely.
- Two subnets within the VPC: one for each instance.
- Security groups to:
  - Allow communication between the instances.
  - Expose both applications to the public via their respective ports.

#### 2. **Define Network Components**

Create a VPC and its associated resources, including subnets, an internet gateway, and route tables. This ensures that both instances are in the same network and can access the internet and each other.

1. **VPC**: Create a VPC to encapsulate the networking environment.
2. **Subnets**: Two subnets, one for each EC2 instance, ensure that they are in isolated IP ranges but can communicate with each other.
3. **Internet Gateway**: Attach an internet gateway to the VPC to provide internet access.
4. **Route Table**: Configure route tables to ensure that traffic is properly routed between the instances and the internet.

#### 3. **Configure Security Groups**

Security groups are essential for controlling traffic flow to and from the EC2 instances.

1. **Flask Security Group**:
   - Allow incoming traffic on port 5000 (Flask default).
   - Allow communication from the Express instance (using its private IP range).
   - Allow SSH access (port 22) for management.

2. **Express Security Group**:
   - Allow incoming traffic on port 3000 (Express default).
   - Allow communication from the Flask instance (using its private IP range).
   - Allow SSH access (port 22) for management.

3. **Inter-Instance Communication**: Both instances should allow communication with each other on their respective ports (5000 for Flask, 3000 for Express), ensuring the backend and frontend can interact securely over the private IP addresses.

#### 4. **User Data Scripts**

User data scripts will be used to install and configure the Flask and Express applications automatically upon instance launch.

- **Flask EC2 Instance**: 
  - Install Python and Flask.
  - Configure Flask to run on port 5000.
  - Start the Flask app using a system process manager or in the background.

- **Express EC2 Instance**: 
  - Install Node.js and Express.
  - Configure Express to run on port 3000.
  - Start the Express app using a process manager like `pm2` or in the background.

Both user data scripts should ensure the applications start automatically upon boot.

#### 5. **Terraform Workflow**

The Terraform workflow will involve the following key steps:

1. **VPC, Subnets, and Route Tables**:
   - Define a VPC to contain both EC2 instances.
   - Define two subnets within the VPC, one for each instance.
   - Attach an internet gateway to the VPC.
   - Configure route tables to route traffic from the subnets to the internet gateway.

2. **Security Groups**:
   - Create two security groups, one for each instance, allowing traffic as described above (Flask on port 5000, Express on port 3000).
   - Configure inter-instance communication between Flask and Express.

3. **EC2 Instances**:
   - Provision two EC2 instances, one for Flask and one for Express.
   - Associate each instance with the appropriate security group and subnet.
   - Use user data scripts to automatically set up Flask and Express on their respective instances.

4. **Outputs**:
   - Output the public IP addresses of both instances for access to the applications.

#### 6. **Deploying with Terraform**

Once the Terraform files are created and configured, follow these steps to deploy the infrastructure:

1. **Initialize Terraform**: Run `terraform init` to download necessary providers and initialize the working directory.

2. **Plan the Deployment**: Run `terraform plan` to see the resources that will be created.

3. **Apply the Configuration**: Run `terraform apply` to provision the VPC, subnets, security groups, and EC2 instances.

   After applying, Terraform will output the public IP addresses of both the Flask and Express instances.

#### 7. **Testing and Validation**

1. **Access Flask Application**: Using the public IP address of the Flask EC2 instance, visit `http://<Flask-IP>:5000` to verify that the Flask application is running and accessible.

2. **Access Express Application**: Using the public IP address of the Express EC2 instance, visit `http://<Express-IP>:3000` to verify that the Express application is running and accessible.

3. **Verify Communication Between Instances**: Ensure that the Flask and Express instances can communicate by testing API calls or any other form of communication required for your specific application.

---

### Summary of Deliverables

1. **Terraform Configuration Files**: These files define the networking, security groups, and EC2 instances to host the Flask and Express applications.
2. **Two Working EC2 Instances**: One instance for the Flask backend (running on port 5000) and one for the Express frontend (running on port 3000).
3. **Security Group Configuration**: Security groups are configured to allow public access to the Flask and Express applications and to allow inter-instance communication.
4. **User Data Scripts**: Scripts that automatically install and start Flask and Express upon instance startup.

This setup ensures that Flask and Express are deployed on separate instances but can still communicate and are accessible to users over the internet.
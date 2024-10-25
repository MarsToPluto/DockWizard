
---

# **DockWizard**  
*Your All-in-One DevOps Automation Tool*  

DockWizard simplifies the process of setting up essential development infrastructure by automating the installation and configuration of Docker, Jenkins, Nginx, MySQL/MongoDB, Certbot, and more. Perfect for beginners looking to save time and avoid complex manual setups.

---

## **Features**  
- **Docker & Docker Compose**: Automated installation and configuration.
- **Jenkins Setup**: Easily deploy a Jenkins instance with admin credentials.
- **Nginx Configuration with Certbot**: Customizable settings like domain and proxy pass, with SSL generation.  
- **Database Support**: Install and configure MySQL or MongoDB containers.  
- **Network Management**: Create Docker networks with custom names.  
- **Environment Variables Handling**: Automatically generate `.env` files from a `.PLUTO` configuration file.

---

## **Prerequisites**  
- Linux-based OS (Ubuntu, Debian, etc.)  
- Root or sudo access  
- Basic knowledge of command-line tools  

---

## **Installation**  
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/MarsToPluto/DockWizard
   cd DockWizard
   ```

2. **Create Your `.PLUTO` File**:  
   Add your configuration variables inside a `.PLUTO` file:
   ```bash
   cat > .PLUTO <<EOF
   DOMAIN=mydomain.com
   MYSQL_USER=root
   MYSQL_PASS=password123
   NETWORK_NAME=dockwizard_net
   EOF
   ```

3. **Make the Setup Script Executable**:
   ```bash
   chmod +x setup_tool.sh
   ```

---

## **Usage**  
Run the setup tool to begin the installation and configuration:
```bash
./setup_tool.sh
```

You will be guided through the setup process, with options to:
- Install Docker and Docker Compose  
- Deploy Jenkins  
- Configure Nginx with Certbot SSL  
- Install MySQL or MongoDB  
- Create Docker networks  
- Generate `.env` files for container use  

---

## **Customizing Nginx**  
You can modify **Nginx settings** (like domain and proxy pass) directly in the setup prompts or through the `nginx.conf` template provided in the tool.

---

## **Generated Files**  
- **.env**: Contains environment variables for your containers.  
- **nginx.conf**: Custom Nginx configuration template.  

---

## **Contributing**  
Feel free to fork the repository and submit pull requests to enhance DockWizard.  

---

## **License**  
This project is licensed under the MIT License. See the `LICENSE` file for more information.

---

## **Support**  
If you encounter any issues, please open an issue on the repository or contact the maintainer.

---

DockWizard takes the hassle out of DevOps so you can focus on building your project! 🚀

---
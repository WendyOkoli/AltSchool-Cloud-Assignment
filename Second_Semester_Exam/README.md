# Automation of LAMP Stack Deployment on Ubuntu Servers: Vagrant, Ansible, and Bash Script 

## Introduction
 This documentation outlines a streamlined approach to automate the deployment of a LAMP (Linux, Apache, MySQL, PHP) stack on Ubuntu-based servers using Vagrant, Ansible, and Bash scripting. 

 ## Objectives
 
Automate the provisioning of two Ubuntu-based servers, named “Master” and “Slave”, using Vagrant.
On the Master node, create a bash script to automate the deployment of a LAMP (Linux, Apache, MySQL, PHP) stack.
This script should clone a PHP application from GitHub, install all necessary packages, and configure Apache web server and MySQL. 
Ensure the bash script is reusable and readable.
Using an Ansible playbook:
Execute the bash script on the Slave node and verify that the PHP application is accessible through the VM’s IP address (take screenshot of this as evidence)
Create a cron job to check the server’s uptime every 12 am.

## Steps used to achieve the aforementioned objectives

1. I created and automated the provisioning of two Ubuntu Servers - Master and Slave. I edited the configuration of their vagrant files, changing the hostname and disabling the SSH insert key.
   
![Master vagrantfile](/Second_Semester_Exam/Images/Master_vagrantfile.png)

![Slave vagrantfile](/Second_Semester_Exam/Images/Slave_vagrantfile.png)

2. I created the public keys of the two machines and had them copied and pasted interchangeably. I also set the ssh config file pub key and password authentication to yes. this was done to enable connection between the two machines

```
ssh-keygen -t ed25519 -C 

```

![Master PUB Key](/Second_Semester_Exam/Images/Master_ssh-keygen.png)

![Slave PUB key](/Second_Semester_Exam/Images/Slave_ssh-keygen.png)

SSH Config
```
Sudo nano /etc/ssh/sshd_config
```

![Master ssh config](/Second_Semester_Exam/Images/Master_sshd_config.png)

![Slave sh config](/Second_Semester_Exam/Images/Slave_ssh_config.png)

3. I created a folder called Ansible and created my inventory, my script and playbook.

i. With the inventory created, I pinged my slave machine from the master.
```
ansible all -m ping -i inventory
```

![Slave ping](/Second_Semester_Exam/Images/Ansible_Slave_Ping.png)

Inventory file

![Inventory](/Second_Semester_Exam/Images/Inventory.png)

ii. The script I created in the Ansible folder - `myLAMP.sh`. It is a readable and reusable script that will aid in the automation and installation of dependencies needed for my LAMP deployment. Here is what the script looks like

```
#!/bin/bash

# Update system
echo "Updating system..."
sudo apt update -y

# Install Apache
echo "Installing Apache..."
sudo apt install apache2 -y

# Add PHP repository and update
echo "Adding PHP repository..."
sudo add-apt-repository ppa:ondrej/php --y
sudo apt update -y

# Install PHP and necessary extensions
echo "Installing PHP..."
sudo apt install php8.2 php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y

# Enable rewrite and restart Apache
echo "Enabling rewrite module and restarting Apache..."
sudo a2enmod rewrite
sudo systemctl res# Install Composer
echo "Installing Composer..."
cd /usr/bin
#install composer globally
sudo curl -sS https://getcomposer.org/installer | sudo php -q
sudo mv composer.phar composer

# Clone Laravel and install dependencies
echo "Cloning Laravel and installing dependencies..."
cd /var/www/
sudo git clone https://github.com/laravel/laravel.git
sudo chown -R $USER:$USER /var/www/laravel
cd laravel/
install composer autoloader
composer install --optimize-autoloader --no-dev --no-interaction
composer update --no-interaction

# Copy .env file and set permissions
echo "Setting up Laravel..."
sudo cp .env.example .env
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache

# Configure Apache site
echo "Configuring Apache site..."
cd /etc/apache2/sites-available/
echo '<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/laravel/public
    <Directory /var/www/laravel>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>' | sudo tee latest.conf
sudo a2ensite latest.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# Install and start MySQL
echo "Installing MySQL..."
sudo apt install mysql-server -y
sudo apt install mysql-client -y
sudo systemctl start mysql
sudo mysql -uroot -e "CREATE DATABASE FlorenceOkoli;"
sudo mysql -uroot -e "CREATE USER 'florence'@'localhost' IDENTIFIED BY 'wendy';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON FlorenceOkoli.* TO 'florence'@'localhost';"

# Configure Laravel .env and run migrations
echo "Configuring Laravel..."
cd /var/www/laravel
sudo sed -i "23 s/^#//g" .env
sudo sed -i "24 s/^#//g" .env
sudo sed -i "25 s/^#//g" .env
sudo sed -i "26 s/^#//g" .env
sudo sed -i "27 s/^#//g" .env
sudo sed -i '22 s/=sqlite/=mysql/' .env
sudo sed -i '23 s/=127.0.0.1/=localhost/' .env
sudo sed -i '24 s/=3306/=3306/' .env
sudo sed -i '25 s/=laravel/=FlorenceOkoli/' .env
sudo sed -i '26 s/=root/=florence/' .env
sudo sed -i '27 s/=/=wendy/' .env
sudo php artisan key:generate
sudo php artisan storage:link
sudo php artisan migrate
sudo php artisan db:seed
sudo systemctl restart apache2

echo "Laravel deployment is successful!"
```

A snippet of the script below

![myLAMP.sh](/Second_Semester_Exam/Images/myLAMP.sh.png)

iii. I created an Ansible playbook - `myLAMP.yml` to execute my `myLAMP.sh` script on my slave machine. I also added a cron job task that checks the uptime of the server every 12 am to the playbook.

```
---
- hosts: 192.168.56.33
  become: yes
  tasks:
    - name: Copy bash script to slave node
      copy:
        src: /home/vagrant/Ansible/myLAMP.sh
        dest: /home/vagrant/myLAMP.sh
        mode: 0755

    - name: Execute bash script on slave node
      shell: /home/vagrant/myLAMP.sh

    - name: Set cron job to check uptime of the server every 12 am
      cron:
        name: Check uptime every 12 am
        minute: "0"
        hour: "0"
        job: "/usr/bin/uptime > /var/log/uptime.log"

    - name: Check Server Uptime
      command: uptime -p
      register: uptime_out

    - name: Print Out Server Up-Time in Play
      debug:
        var: uptime_out.stdout

    - name: Check PHP Application Accessibility
      uri:
        url: http://192.168.56.33
        return_content: yes
      register: php_app_response
      ignore_errors: true

    - name: Display Message if PHP Application is Accessible
      debug:
        msg: "PHP Application is Accessible"
      when: php_app_response.rc == 0
...
```

Here is a snippet 

![myLAMP.yml](/Second_Semester_Exam/Images/myLAMP.yml.png)

The successful output after several errors

![myLAMP.yml output](/Second_Semester_Exam/Images/myLAMP.yml_Output.png)

4. After deployment, I verified that the PHP application is accessible through the Slave node's IP address via the web browser.
   
![Web browser](/Second_Semester_Exam/Images/Laravel_Deployment_on_slave.png)

## Conclusion

In conclusion, this documentation demonstrates the power of automation using Vagrant, Ansible, and Bash scripting to deploy a LAMP stack and PHP application on Ubuntu servers efficiently. By following this guide, you'll be equipped to automate server provisioning, application deployment, and monitoring tasks, improving the reliability and scalability of your infrastructure.



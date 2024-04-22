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
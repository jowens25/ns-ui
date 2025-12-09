rm -rf /var/www/ns
cp -r build/web /var/www/ns
chown -R www-data:www-data /var/www/ns
chmod -R 755 /var/www/ns
chmod 777 /var/www/ns

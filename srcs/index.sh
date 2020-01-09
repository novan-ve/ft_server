if [ "$1" = "on" ]; then
	sed -i 's/\boff/on/' /etc/nginx/sites-available/default
	service nginx restart
elif [ "$1" = "off" ]; then
	sed -i 's/\bon/off/' /etc/nginx/sites-available/default
	service nginx restart
fi

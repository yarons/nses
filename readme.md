If you run the script from Win10 using WSL, make sure to use this code for copying without Nano trailing whitespaces bug (2017):
https://github.com/Microsoft/WSL/issues/2006

To solve:

1. Install autohotkey and run the script.
2. Start Nano in the following way, paste the script, exit with saving and it will run:

bash /dev/fd/3 3<<-'WSLNANO'
	sed -i 's/bind ^J enter main//g' /etc/nanorc # Clean nanorc from previous relevant conf.
	bash -c "echo 'bind ^J enter main' >> /etc/nanorc"
	rm ~/script.sh ; nano ~/script.sh && chmod +x ~/script.sh && bash ~/script.sh && rm ~/script.sh
	sed -i 's/bind ^J enter main//g' /etc/nanorc
WSLNANO

NSES stands for Nginx Server Environment Setup. nses.sh is a script that let's you to create a minimalist Nginx server environment suitable for small to medium sites (minimal configuration).

The script includes a nice maker I wrote that creates a server block with the domain you provide as an argument in execution. It also create a Let'sEncrypt signed certificate to that domain and changes the server block as well.

The script has some leads (leading whitespaces) even outside its function, so stripping these out in copying (so they wouldn't be part of the script when it's in copied to clipboard is essential.

**Running the script from Win10 WSL:**

Make sure to use this code for copying without Nano trailing whitespaces bug (2017):
https://github.com/Microsoft/WSL/issues/2006

To solve:

1. Install autohotkey and run the script (trimClipboard.ahk).
2. Start Nano in the following way, paste the script, exit with saving and it will run:

bash /dev/fd/3 3<<-'WSLNANO'
	sed -i 's/bind ^J enter main//g' /etc/nanorc # Clean nanorc from previous relevant conf.
	bash -c "echo 'bind ^J enter main' >> /etc/nanorc"
	rm ~/script.sh ; nano ~/script.sh && chmod +x ~/script.sh && bash ~/script.sh && rm ~/script.sh
	sed -i 's/bind ^J enter main//g' /etc/nanorc
WSLNANO

**Running the script from nix:

Make sure to strip leading tabs when copying in any way you wish (I only know the way I described above in Windows with AHk).

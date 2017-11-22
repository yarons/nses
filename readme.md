NSES stands for Nginx Server Environment Setup. *nses.sh* is a script that let's you to create a minimalist Nginx server environment. This is basically the only file of this program. The reason for any other code file in the repository is mentioned below.

* This program is aimed for pure Debian based systems, as it also adds a few aliases and programs.
* This program should be used after basic configuration of `/etc/nginx/nginx.conf`.

**WSM - Webapp Substrate Maker:**
The script includes a nice maker I've named "WSM" which does the following actions in execution (after providing a domain+tld as an argument to the script's Bash alias).

The Bash alias (also created by the script), is wsm, so type in Bash prompt:

`wsm domain.tld`

*The maker does:*

1. Ceates an Nginx webapp conf file in `/etc/nginx/sites-available` with the domain you provide as an argument in execution.
2. Creates an accordant symlink `/etc/nginx/sites-enabled`.
2. Creates a Let'sEncrypt signed certificate to that domain.
3. Changes the server block in accordance.
4. Creates a mysql, authenticated, all privilieged user, a DB, and a password, all as your domain (password should be changed after NSES exeuction per each domain).

**Stripping leading tabs**

The script has some leads (leading whitespaces) even outside its function, so stripping these out in copying (so they wouldn't be part of the script when it's in copied to clipboard is essential.

__Running the script from Win10 WSL:__

Make sure to use this code for copying without Nano trailing whitespaces bug (2017):
https://github.com/Microsoft/WSL/issues/2006

*To solve:*

1. Install autohotkey and run the script (trimClipboard.ahk).
2. Start Nano in the following way, paste the script, exit with saving and it will run:

`
bash /dev/fd/3 3<<-'WSLNANO'
	sed -i 's/bind ^J enter main//g' /etc/nanorc # Clean nanorc from previous relevant conf.
	bash -c "echo 'bind ^J enter main' >> /etc/nanorc"
	rm ~/script.sh ; nano ~/script.sh && chmod +x ~/script.sh && bash ~/script.sh && rm ~/script.sh
	sed -i 's/bind ^J enter main//g' /etc/nanorc
WSLNANO
`

__Running the script from nix:__

Make sure to strip leading tabs when copying in any way you wish (I only know the way I described above in Windows with AHk).

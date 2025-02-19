# arch-autoupdater
A simple sh script that updates the pacman repos at a defined hour every day

1. Run `Sudo pacman -S cron curl` to install curl and corn. For cron is preferred cronie option if asked.

3. Run `sudo rm -f /tmp/setup_update_script.sh && sudo curl -sSL https://raw.githubusercontent.com/Flavio-coding/arch-autoupdater/main/setup_update_script.sh -o /tmp/setup_update_script.sh && sudo bash /tmp/setup_update_script.sh` to start the installation script.

4. Consider improving this project!

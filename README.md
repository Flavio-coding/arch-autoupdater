# arch-autoupdater
A simple sh script that updates the pacman repos at a defined hour every day

1. Run `sudo pacman -S curl --noconfirm`.

2. Run `sudo rm -f /tmp/setup_update_script.sh && sudo curl -sSL https://raw.githubusercontent.com/Flavio-coding/arch-autoupdater/main/setup_update_script.sh -o /tmp/setup_update_script.sh && sudo bash /tmp/setup_update_script.sh` to start the installation script.

3. Consider improving this project!

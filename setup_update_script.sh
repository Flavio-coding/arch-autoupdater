#!/bin/bash

# Header
echo "=============================="
echo "         AUTO-UPDATER         "
echo "=============================="
echo "This script allows you to either install a new auto-update rule or view existing ones."

# Function to install a new update rule
install_new_rule() {
    echo "Installing a new update rule..."

    # Path for the update script
    SCRIPT_PATH="/usr/local/bin/update_script.sh"

    # Check if the update script is already installed
    if [ -f "$SCRIPT_PATH" ]; then
        read -p "The update script is already installed. Do you want to reinstall it? [y/n]: " reinstall_choice
        if [[ "$reinstall_choice" != "y" ]]; then
            echo "Exiting without changes."
            rm -- "$0"  # Auto-delete the script
            exit 0
        fi
    fi

    # Ask user for the hour in 24-hour format
    while true; do
        read -p "Please enter the hour in 24-hour format (00-23): " hour
        # Check if the hour is valid
        if [[ "$hour" =~ ^([01]?[0-9]|2[0-3])$ ]]; then
            break
        else
            echo "Invalid hour. Please enter a valid hour between 00 and 23."
        fi
    done

    # Ask user for the minutes (00-59)
    while true; do
        read -p "Please enter the minutes (00-59): " minute
        # Check if the minutes are valid
        if [[ "$minute" =~ ^([0-5]?[0-9])$ ]]; then
            break
        else
            echo "Invalid minutes. Please enter valid minutes between 00 and 59."
        fi
    done

    # Create the update script
    echo "#!/bin/bash" | sudo tee $SCRIPT_PATH > /dev/null
    echo "sudo pacman -Syu --noconfirm" | sudo tee -a $SCRIPT_PATH > /dev/null

    # Make the update script executable
    sudo chmod +x $SCRIPT_PATH

    # Add the cron job
    (crontab -l 2>/dev/null; echo "$minute $hour * * * $SCRIPT_PATH") | sudo crontab -

    # Configure sudo to not require a password for the command
    echo "$(whoami) ALL=(ALL) NOPASSWD: $SCRIPT_PATH" | sudo tee /etc/sudoers.d/update_script > /dev/null

    # Set the correct permissions
    sudo chmod 440 /etc/sudoers.d/update_script

    echo "Setup completed! The update script will run every day at $hour:$minute."

    # Prompt to reboot the system
    read -p "Do you want to reboot the system now? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        echo "Rebooting..."
        sudo reboot
    else
        echo "You can reboot the system later to apply changes."
    fi
}

# Function to view and remove existing update rules
view_and_remove_rules() {
    echo "Existing update rules:"

    # List the cron jobs related to the update script
    cron_jobs=$(sudo crontab -l 2>/dev/null | grep "/usr/local/bin/update_script.sh")

    if [[ -z "$cron_jobs" ]]; then
        echo "No existing update rules found."
        return
    fi

    # Show existing cron jobs
    echo "$cron_jobs" | nl

    # Ask if the user wants to remove a cron job
    read -p "Do you want to remove an update rule? (y/n): " remove_choice
    if [[ "$remove_choice" == "y" ]]; then
        read -p "Enter the number of the rule to remove: " job_number
        cron_line=$(echo "$cron_jobs" | sed -n "${job_number}p")
        if [[ -n "$cron_line" ]]; then
            # Remove the selected cron job
            sudo crontab -l | grep -v "$cron_line" | sudo crontab -
            echo "The selected update rule has been removed."
        else
            echo "Invalid number. No rule removed."
        fi
    fi
}

# Main menu loop
while true; do
    echo "Choose an option:"
    echo "1. Install a new auto-update rule"
    echo "2. View and remove existing auto-update rules"
    echo "3. Exit"
    read -p "Enter your choice [1/2/3]: " choice

    case "$choice" in
        1)
            install_new_rule
            ;;
        2)
            view_and_remove_rules
            ;;
        3)
            echo "Exiting the script."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done

# Auto-delete the script
rm -- "$0"

#!/bin/bash

# ===============================================
# VirtualBox Headless Manager Script
# ===============================================

echo "========== VirtualBox Headless Manager =========="

PS3="Select an option: "
options=(
    "List all VMs"
    "List running VMs"
    "Start VM headless"
    "Stop VM"
    "Pause VM"
    "Resume VM"
    "Exit"
)

select opt in "${options[@]}"; do
    case $REPLY in
        1)  # List all VMs
            echo "All VirtualBox VMs:"
            VBoxManage list vms
            ;;
        2)  # List running VMs
            echo "Running VirtualBox VMs:"
            VBoxManage list runningvms
            ;;
        3)  # Start VM headless
            echo "Available VMs:"
            VBoxManage list vms | nl
            read -p "Enter the number of the VM to start headless: " vm_number
            vm_name=$(VBoxManage list vms | sed -n "${vm_number}p" | awk -F '"' '{print $2}')
            if [ -z "$vm_name" ]; then
                echo "Invalid selection."
            else
                echo "Starting '$vm_name' in headless mode..."
                VBoxManage startvm "$vm_name" --type headless
            fi
            ;;
        4)  # Stop VM
            echo "Running VMs:"
            VBoxManage list runningvms | nl
            read -p "Enter the number of the VM to stop: " vm_number
            vm_name=$(VBoxManage list runningvms | sed -n "${vm_number}p" | awk -F '"' '{print $2}')
            if [ -z "$vm_name" ]; then
                echo "Invalid selection."
            else
                echo "Stopping '$vm_name'..."
                VBoxManage controlvm "$vm_name" poweroff
            fi
            ;;
        5)  # Pause VM
            echo "Running VMs:"
            VBoxManage list runningvms | nl
            read -p "Enter the number of the VM to pause: " vm_number
            vm_name=$(VBoxManage list runningvms | sed -n "${vm_number}p" | awk -F '"' '{print $2}')
            if [ -z "$vm_name" ]; then
                echo "Invalid selection."
            else
                echo "Pausing '$vm_name'..."
                VBoxManage controlvm "$vm_name" pause
            fi
            ;;
        6)  # Resume VM
            echo "Paused VMs (running state shown):"
            VBoxManage list runningvms | nl
            read -p "Enter the number of the VM to resume: " vm_number
            vm_name=$(VBoxManage list runningvms | sed -n "${vm_number}p" | awk -F '"' '{print $2}')
            if [ -z "$vm_name" ]; then
                echo "Invalid selection."
            else
                echo "Resuming '$vm_name'..."
                VBoxManage controlvm "$vm_name" resume
            fi
            ;;
        7)  # Exit
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
    echo "================================================="
done

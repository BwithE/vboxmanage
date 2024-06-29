Clear-Host
# Function to get current user's username
function Get-CurrentUsername {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $username = $currentUser.Name.Split("\")[1]
    return $username
}

# Function to display menu and handle user input
function Show-Menu {
    
    Write-Host "#############################################" -ForegroundColor Blue
    Write-Host "                VBManage"
    Write-Host "#############################################" -ForegroundColor Blue
    Write-Host "What would you like to do?"
    Write-Host "1) Create VM"
    Write-Host "2) Start VM"
    Write-Host "3) Stop VM"
    Write-Host "4) Snapshot VM"
    Write-Host "5) Edit VM (CPU, RAM, Storage, Video Memory)"
    Write-Host "6) Delete VM"
    Write-Host "7) List All VMs"
    Write-Host "*) EXIT"
    $choice = Read-Host "Enter your choice"
    return $choice
}

# Function to display Edit VM menu and handle user input
function Show-EditMenu {
    do {
        
        Write-Host "#############################################" -ForegroundColor Yellow
        Write-Host "Edit VM Options:"
        Write-Host "1) Change CPUs"
        Write-Host "2) Change RAM"
        Write-Host "3) Change Storage Size (Virtual Disk)"
        Write-Host "4) Change Video Memory"
        Write-Host "*) EXIT"
        $choice = Read-Host "Enter your choice"

        switch ($choice) {
            1 {
                List-VMs
                Write-Host "#############################################" -ForegroundColor Yellow
                $vmname = Read-Host "Enter the name of the VM to edit"
                $newCPUs = Read-Host "Enter the new number of CPUs"
                & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "$vmname" --cpus $newCPUs
                Write-Host "#############################################" -ForegroundColor Yellow
                Write-Host "CPUs updated to $newCPUs for VM '$vmname'."
                Read-Host "Press Enter to continue..."
            }
            2 {
                List-VMs
                Write-Host "#############################################" -ForegroundColor Yellow
                $vmname = Read-Host "Enter the name of the VM to edit"
                $newRAM = Read-Host "Enter the new amount of RAM (in MB)"
                & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "$vmname" --memory $newRAM
                Write-Host "#############################################" -ForegroundColor Yellow
                Write-Host "RAM updated to $newRAM MB for VM '$vmname'."
                Read-Host "Press Enter to continue..."
            }
            3 {
                List-VMs
                Write-Host "#############################################" -ForegroundColor Yellow
                $vmname = Read-Host "Enter the name of the VM to edit"
                $newDiskSize = Read-Host "Enter the new size of the virtual disk (in MB)"
                & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifymedium disk "$vmname" --resize $newDiskSize
                Write-Host "#############################################" -ForegroundColor Yellow
                Write-Host "Virtual disk size updated to $newDiskSize MB for VM '$vmname'."
                Read-Host "Press Enter to continue..."
            }
            4 {
                List-VMs
                Write-Host "#############################################" -ForegroundColor Yellow
                $vmname = Read-Host "Enter the name of the VM to edit"
                $newVideoMemory = Read-Host "Enter the new amount of video memory (in MB)"
                & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "$vmname" --vram $newVideoMemory
                Write-Host "#############################################" -ForegroundColor Yellow
                Write-Host "Video memory updated to $newVideoMemory MB for VM '$vmname'."
                Read-Host "Press Enter to continue..."
            }
            default {
                Write-Host "#############################################" -ForegroundColor Yellow
                Write-Host "EXITING VBManage"
                exit
            }
        }
    } while ($true)
}

# Function to display Snapshot VM menu and handle user input
function Show-SnapshotMenu {
    do {
        
        Write-Host "#############################################" -ForegroundColor Yellow
        Write-Host "Snapshot VM Options:"
        Write-Host "1) Take a snapshot"
        Write-Host "2) Revert to a snapshot"
        Write-Host "3) Delete a snapshot"
        Write-Host "*) EXIT"
        $choice = Read-Host "Enter your choice"

        switch ($choice) {
            1 {
                List-VMs
                Write-Host "#############################################" -ForegroundColor Yellow
                $vmname = Read-Host "Enter the name of the VM to snapshot"
                List-Snapshots -vmname $vmname
                $snapshotname = Read-Host "Enter the name for the snapshot"
                & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" snapshot "$vmname" take "$snapshotname"
                Write-Host "#############################################" -ForegroundColor Yellow
                Write-Host "Snapshot '$snapshotname' created for VM '$vmname'."
                Read-Host "Press Enter to continue..."
            }
            2 {
                List-VMs
                Write-Host "#############################################" -ForegroundColor Yellow
                $vmname = Read-Host "Enter the name of the VM to revert to a snapshot"
                List-Snapshots -vmname $vmname
                $snapshotname = Read-Host "Enter the name of the snapshot to revert to"
                & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" snapshot "$vmname" restore "$snapshotname"
                Write-Host "#############################################" -ForegroundColor Yellow
                Write-Host "VM '$vmname' reverted to snapshot '$snapshotname'."
                Read-Host "Press Enter to continue..."
            }
            3 {
                List-VMs
                Write-Host "#############################################" -ForegroundColor Yellow
                $vmname = Read-Host "Enter the name of the VM to delete a snapshot"
                $snapshotToDelete = Choose-SnapshotToDelete -vmname $vmname
                & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" snapshot "$vmname" delete "$snapshotToDelete"
                Write-Host "#############################################" -ForegroundColor Yellow
                Write-Host "Snapshot '$snapshotToDelete' deleted for VM '$vmname'."
                Read-Host "Press Enter to continue..."
            }
            default {
                Write-Host "#############################################" -ForegroundColor Yellow
                Write-Host "EXITING VBManage"
                exit
            }
        }
    } while ($true)
}

# Function to delete a VM
function Delete-VM {
    
    Write-Host "#############################################" -ForegroundColor Yellow
    List-VMs
    Write-Host "#############################################" -ForegroundColor Yellow
    $vmname = Read-Host "Enter the name of the VM to delete"

    # Example command to delete a VM
    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" unregistervm "$vmname" --delete

    Write-Host "#############################################" -ForegroundColor Yellow
    Write-Host "VM '$vmname' deleted."
    Read-Host "Press Enter to continue..."
}

# Function to list snapshots for a VM
function List-Snapshots {
    param(
        [string]$vmname
    )

    Write-Host "#############################################" -ForegroundColor Yellow
    Write-Host "Listing snapshots for VM '$vmname'..."
    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" snapshot "$vmname" list --machinereadable | ForEach-Object {
        if ($_ -match '^SnapshotName.*="(.+)"$') {
            $snapshotName = $matches[1]
            Write-Host "$($snapshotName)"
        }
    }
    Write-Host "#############################################" -ForegroundColor Yellow
}

# Function to list all existing VM names
function List-VMs {
    
    Write-Host "#############################################" -ForegroundColor Yellow
    Write-Host "Listing all existing VMs..."

    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" list vms | ForEach-Object {
        if ($_ -match '"(.+)"') {
            $vmName = $matches[1]
            Write-Host "$($vmName)"
        }
    }
}

# Main loop
while ($true) {
    $choice = Show-Menu

    switch ($choice) {
        1 {
            List-VMs
            Write-Host "#############################################" -ForegroundColor Yellow
            $vmname = Read-Host "Enter the name for the new VM"
            $ostype = Read-Host "Enter the type of the guest OS (EX: Windows10_64, Linux_64, Debian_64, Ubuntu_64)"
            $isofile = Read-Host "Enter the path to the ISO file for the guest OS"
            $cpus = Read-Host "Enter the number of CPUs"
            $ram = Read-Host "Enter the amount of RAM (in MB)"
            $diskSize = 20480  # 20GB in MB (20 * 1024)
            $videoMemory = 16  # Default video memory in MB

            # Set video memory based on OS type
            if ($ostype -match "Windows") {
                $videoMemory = 64
            }

            # Get current username
            $username = Get-CurrentUsername

            # Create directory if it doesn't exist
            $vmPath = "C:\Users\$username\VirtualBox VMs\$vmname"
            if (!(Test-Path $vmPath)) {
                New-Item -ItemType Directory -Path $vmPath | Out-Null
            }

            # Example command to create VM with 20GB virtual disk and specified video memory
            & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createvm --name "$vmname" --ostype "$ostype" --register
            & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "$vmname" --cpus $cpus --memory $ram --vram $videoMemory
            & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storagectl "$vmname" --name "SATA Controller" --add sata --controller IntelAhci
            & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createhd --filename "$vmPath\$vmname.vdi" --size $diskSize --format VDI
            & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach "$vmname" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vmPath\$vmname.vdi"
            & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach "$vmname" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium "$isofile"

            Write-Host "#############################################" -ForegroundColor Yellow
            Write-Host "VM '$vmname' created with $cpus CPUs, $ram MB RAM, 20GB virtual disk, and $videoMemory MB video memory."
            Read-Host "Press Enter to continue..."
        }
        2 {
            List-VMs
            Write-Host "#############################################" -ForegroundColor Yellow
            $vmname = Read-Host "Enter the name of the VM to start"

            # Example command to start VM
            & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "$vmname" --type headless

            Write-Host "#############################################" -ForegroundColor Yellow
            Write-Host "VM '$vmname' started."
            Read-Host "Press Enter to continue..."
        }
        3 {
            List-VMs
            Write-Host "#############################################" -ForegroundColor Yellow
            $vmname = Read-Host "Enter the name of the VM to stop"

            # Example command to stop VM
            & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" controlvm "$vmname" poweroff

            Write-Host "#############################################" -ForegroundColor Yellow
            Write-Host "VM '$vmname' stopped."
            Read-Host "Press Enter to continue..."
        }
        4 {
            Show-SnapshotMenu
        }
        5 {
            Show-EditMenu
        }
        6 {
            Delete-VM
        }
        7 {
            List-VMs
        }
        default {
            
            Write-Host "#############################################" -ForegroundColor Yellow
            Write-Host "EXITING VBManage"
            exit
        }
    }
}


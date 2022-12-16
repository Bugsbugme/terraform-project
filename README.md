# Terraform "Infrastructure as Code" project

## Create some basic infrastructure on AWS with Terraform

Used the tutorial here: https://www.youtube.com/watch?v=iRaai1IBlB0

## Some important changes

> - When using WSL in Windows, the Remote SSH extension for VS Code will still be looking in your Windows .ssh folder for configuration settings.
>
>   > You can fix this by copying the contents of your WSL .ssh folder to the Windows one, then making a symlink in WSL to the Windows .ssh folder.
>   > That way both WSL and the extension will be able to see the same files and you can still use WSL to edit/create files inside of it.
>
> - It's not necessary to define the interpreter inside the provisioner block. Terraform will choose the correct one automatically.

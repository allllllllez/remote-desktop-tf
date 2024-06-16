<powershell>
Initialize-ECSAgent -Cluster ${var.cluster_name} -EnableTaskIAMRole -LoggingDrivers '["json-file","awslogs"]'
# Git
# get latest download url for git-for-windows 64-bit exe
$git_url = "https://api.github.com/repos/git-for-windows/git/releases/latest"
$asset = Invoke-RestMethod -Method Get -Uri $git_url | % assets | where name -like "*64-bit.exe"
echo "git_url: "$git_url
echo "asset: "$asset

# download installer
$installer = "$env:temp\$($asset.name)"
echo "installer: "$installer 
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer

# inf file
# https://github.com/git-for-windows/git/wiki/Silent-or-Unattended-Installation
$git_install_inf = "$env:temp\setup.inf"
Set-Content -Path "$git_install_inf" -Force -Value @'
[Setup]
Lang=default
Dir=C:\Git
Group=Git
NoIcons=0
SetupType=default
Components=
Tasks=
PathOption=Cmd
SSHOption=OpenSSH
CRLFOption=CRLFCommitAsIs
'@

# run installer
$install_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_install_inf"""
Start-Process -FilePath $installer -ArgumentList $install_args -Wait

# Add git path
$ENV:Path="C:\Git\bin;"+$ENV:Path

</powershell>
<persist>true</persist>

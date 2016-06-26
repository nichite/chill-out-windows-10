#---------------------------------------------------------------
# chill-out-windows-10.ps1
# Nicolas Hite
# 06/25/16
# MIT License
#
# A powershell script to make Windows 10 decidedly more chill.
# Removes pushy product suggestions and targeted ads, notifications,
# useless Windows search add-ons, elevated-privilege challenges,
# and bloated built-in apps. Most of these changes are simple 
# modifications to the registry.
#
# IMPORTANT: do NOT run this script unless you know what you're
# doing. I'm just some random guy on the internet, and blindly
# running scripts in admin mode on your machine is a fantastic 
# way to get malware, delete/corrupt files, or just ruin your
# machine. Read through this to make sure for yourself that
# there's no funny business.
#---------------------------------------------------------------

#---------------------------------------------------------------
# This function adds or sets a registry value for a given path.
# If that path doesn't exist, make it.
#---------------------------------------------------------------
function Set-Reg ($regPath, $name, $value) {

    If(!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    New-ItemProperty -Path $regPath -Name $name -Value $value -PropertyType `
        "DWORD" -Force | Out-Null
}

#---------------------------------------------------------------
# This function announces a new section to work on.
#---------------------------------------------------------------
function Write-Section ($string) {

    Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host $string -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Yellow
}

# Some paths that get used more than once
$ContentDeliveryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$WindowsSearchPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$UACPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"


Write-Section "Disable ad-and-product-related stuff, as well as the action and notification center."


# Don't let apps use your advertising ID.
Write-Host "Disabling use of Advertising Id..."
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
"Enabled" 0x0

# Don't let Microsoft push annoying RSS feeds about its products.
Write-Host "Disabling Microsoft RSS Feeds..."
Set-Reg "HKCU:\SOFTWARE\Microsoft\Feeds" `
"SyncStatus" 0x0

# Turn off tips about Windows. If you're to the point of grabbing a script like this
# off GitHub, chances are you don't need these.
Write-Host "Disabling tips about Windows..."
Set-Reg $ContentDeliveryPath "SoftLandingEnabled" 0x0

# Scrap the whole action center with annoying notifications. There are a few useful
# tiles, but you can perform those actions from the start menu or keyboard shortcuts.
Write-Host "Disabling the Action Center..."
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
"DisableNotificationCenter" 0x1

# Start menu app suggestions are pretty annoying, too.
Write-Host "Disabling Start Menu app suggestions..."
Set-Reg $ContentDeliveryPath "SystemPaneSuggestionsEnabled" 0x0


Write-Section "Streamline Windows search to only grab from your indexed paths."


# Disable Cortana--skip this one if you want. I've never found it
# super useful on Desktop, and it's a memory hog.
# NOTE: this ONLY disables the Cortana personal assistant application. To keep start
# menu search (useful) working, SearchUI.exe must keep running. So it'll still show
# Cortana as running in Task View.
Write-Host "Disabling Cortana..."
Set-Reg $WindowsSearchPath "AllowCortana" 0x0

# Disable Bing search. No one wants these suggestions.
Write-Host "Disabling Bing search..."
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
"BingSearchEnabled" 0x0

# I never liked location-based suggestions in my searches.
Write-Host "Disabling location-based search suggestions..."
Set-Reg $WindowsSearchPath "AllowSearchToUseLocation" 0x0

# Web suggestions in my search menu? No thanks.
Write-Host "Disabling web suggestions in Windows Search..."
Set-Reg $WindowsSearchPath "ConnectedSearchUseWeb" 0x0
Set-Reg $WindowsSearchPath "DisableWebSearch" 0x1


Write-Section "Disable feedback-and-data-collection stuff."


# This one I recommend leaving in (developer bias)--it'll make Windows better. 
# But if you're jumpy about having your data collected (about OS usage), disable it.
Write-Host "Disabling collection of OS usage data..."
Set-Reg "HKLM:\SOFTWARE\Microsoft\SQMClient\Windows" `
"CEIPEnable" 0x0

# Telemetry should be opt-in, but just to make sure it's off...
Write-Host "Disabling telemetry data collection..."
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
"AllowTelemetry" 0x0

# In addition to sending error reports, sometimes Windows will send extra
# data about your usage. If you're skeeved out by this, turn it off.
Write-Host "Disabling send additional info with error reports..."
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" `
"DontSendAdditionalData" 0x1

# This feature is mostly for businesses--it uses peer Windows 10 machines to spread
# updates to each other. However, it's turned on for all editions of Windows,
# and will grab or use you as a host over the internet as well. Disabling this
# will save you some bandwidth and data usage.
Write-Host "Disabling P2P Windows Update download and hosting..."
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" `
"DownloadMode" 0x0


Write-Section "Disabling scheduled tasks related to feedback and location."


# We killed off the CEIP, so we won't need these tasks.
Write-Host "Disabling CEIP scheduled tasks..."
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" |
Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" |
Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" |
Out-Null

# Remove the DMClient task (also sends feedback)
Write-Host "Disabling Feedback scheduled tasks..."
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" |
Out-Null

# Disable location-based tasks and map tasks
Write-Host "Disabling location-based scheduled tasks..."
Disable-ScheduledTask -TaskName "Microsoft\Windows\Location\Notifications" |
Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Maps\MapsToastTask" |
Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Maps\MapsUpdateTask" |
Out-Null


Write-Section "Disable User Account Control."


# This is going to make admins be able to run programs in privileged mode
# without getting prompted. If you're a sysadmin at work, this is bad practice.  
# But it should be no biggie on personal machines.
Write-Host "Disabling Limited User Account..."
Set-Reg $UACPath "EnableLUA" 0x0 "DWORD"
Set-Reg $UACPath "ConsentPromptBehaviorAdmin" 0x0 "DWORD"



Write-Section "Remove unnecessary apps."


# Not even Microsoft can properly elaborate on what this does.
Write-Host "Removing Appconnector..."
Get-AppxPackage *Appconnector* | Remove-AppxPackage

# This vaguely named comm app is pretty mysterious, too.
Write-Host "Removing windowscommunicationsapps..."
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage

# More of the same.
Write-Host "Removing Windows Advertising..."
Get-AppxPackage *advertising* | Remove-AppxPackage

# Stop trying to make Bing happen.
Write-Host "Removing all Bing apps..."
Get-AppxPackage *Bing* | Remove-AppxPackage

# Never heard of anyone who used this.
Write-Host "Removing 'Get Started' App..."
Get-AppxPackage *GetStarted* | Remove-AppxPackage

# Probably should just use Google Maps.
Write-Host "Removing Windows Maps..."
Get-AppxPackage *Microsoft.WindowsMaps* | Remove-AppxPackage

# I never use any of the Xbox apps.
Write-Host "Removing Xbox App..."
Get-AppxPackage *XboxApp* | Remove-AppxPackage

# Or the Windows Phone.
Get-AppxPackage *WindowsPhone* | Remove-AppxPackage

# Surely these are here by mistake...
Write-Host "Removing all Zune apps..."
Get-AppxPackage *zune* | Remove-AppxPackage

# I could see people using these next ones, but I don't.
# Feel free to comment out.
Write-Host "Removing Twitter App..."
Get-AppxPackage *twitter* | Remove-AppxPackage

Write-Host "Removing Skype..."
Get-AppxPackage *skype* | Remove-AppxPackage

Write-Host "Removing Messaging..."
Get-AppxPackage *messaging* | Remove-AppxPackage

Write-Host "Removing People App..."
Get-AppxPackage *people* | Remove-AppxPackage

Write-Host "Removing Photos App..."
Get-AppxPackage *photos* | Remove-AppxPackage

# This is that thing that keeps begging you to get Office.
Write-Host "Removing Office Hub..."
Get-AppxPackage *officehub* | Remove-AppxPackage

# These are probably useful on Windows Phone, but not
# really on desktop.
Write-Host "Removing Alarms App..."
Get-AppxPackage *alarms* | Remove-AppxPackage

Write-Host "Removing Voice Recorder App..."
Get-AppxPackage *recorder* | Remove-AppxPackage


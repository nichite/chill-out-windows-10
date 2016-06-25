# Returns the SID for the current user
function Get-SID() {

    $objUser = New-Object System.Security.Principal.NTAccount($env:USERNAME)
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    return $strSID.Value
}

function Set-Reg ($regPath, $name, $value, $type) {

    If(!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    New-ItemProperty -Path $regPath -Name $name -Value $value -PropertyType `
        $type -Force | Out-Null
}

#---------------------------------------------------------------
# Disable unnecessary, annoying, or invasive user-centric stuff.
#---------------------------------------------------------------
# (NOTE: These settings will only apply to the current user)

# Don't let apps use my advertising ID.
Write-Host "Disabling use of Advertising Id..."
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
"Enabled" 0x0 "DWORD"

# Don't let Microsoft push annoying RSS feeds about its products.
# This will improve performance a bit and could save some disk.
Write-Host "Disabling Microsoft RSS Feeds..."
Set-Reg "HKCU:\SOFTWARE\Microsoft\Feeds" `
"SyncStatus" 0x0 "DWORD"

# Disable Bing search. No one wants these suggestions.
Write-Host "Disabling Bing search..."
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
"BingSearchEnabled" 0x0 "DWORD"

# Turn off tips about Windows. If you're to the point of grabbing a script like this
# off of GitHub, chances are you don't need these.
Write-Host "Disabling tips about Windows..."
$ContentDeliveryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-Reg $ContentDeliveryPath "SoftLandingEnabled" 0x0 "DWORD"

# Start menu app suggestions are pretty annoying, too.
Write-Host "Disabling Start Menu app suggestions..."
Set-Reg $ContentDeliveryPath "SystemPaneSuggestionsEnabled" 0x0 "DWORD"

#---------------------------------------------------------------
# Disable unnecessary features.
#---------------------------------------------------------------

# Scrap the whole action center with annoying notifications. There are a few useful
# tiles, but you can perform those actions from the start menu or keyboard shortcuts.
Write-Host "Disabling the Action Center..."
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
"DisableNotificationCenter" 0x1 "DWORD"

# Disable Cortana--skip this one if you want. I've never found it
# super useful on Desktop, and it's a memory hog.
# NOTE: this ONLY disables the Cortana personal assistant application. To keep start
# menu search (useful) working, SearchUI.exe must keep running. So it'll still show
# Cortana as running in Task View.
Write-Host "Disabling Cortana..."
$WindowsSearchPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Set-Reg $WindowsSearchPath "AllowCortana" 0x0 "DWORD"

# This one I recommend leaving in (developer bias)--it'll make Windows better. 
#But if you're jumpy about having your data collected (about OS usage), disable it.
Write-Host "Disabling collection of OS usage data..."
Set-Reg "HKLM:\SOFTWARE\Microsoft\SQMClient\Windows" `
"CEIPEnable" 0x0 "DWORD"

# Telemetry should be opt-in, but just to make sure it's off...
Write-Host "Disabling telemetry data collection..."
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
"AllowTelemetry" 0x0 "DWORD"

# In addition to sending error reports, sometimes Windows will send extra
# data about your usage. If you're skeeved out by this, turn it off.
Write-Host "Disabling send additional info with error reports..."
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" `
"DontSendAdditionalData" 0x1 "DWORD"

# I never liked location-based suggestions in my searches.
Write-Host "Disabling location-based search suggestions..."
Set-Reg $WindowsSearchPath "AllowSearchToUseLocation" 0x0 "DWORD"

# Web suggestions in my search menu? No thanks.
Write-Host "Disabling web suggestions in Windows Search..."
Set-Reg $WindowsSearchPath "ConnectedSearchUseWeb" 0x0 "DWORD"
Set-Reg $WindowsSearchPath "DisableWebSearch" 0x1 "DWORD"

# This feature is for businesses--it uses peer Windows 10 machines to spread
# updates to each other. However, it's turned on for all editions of Windows,
# and will grab or use you as a host over the internet as well. Disabling this
# will save you some bandwidth and data usage.
Write-Host "Disabling P2P Windows Update download and hosting..."
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" `
"DownloadMode" 0x0 "DWORD"

#---------------------------------------------------------------
# Disable unnecessary scheduled tasks.
#---------------------------------------------------------------

# We killed off the CEIP, so we won't need these tasks.
Write-Host "Disabling CEIP scheduled tasks..."
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"

# Remove the DMClient task (also sends feedback)
Write-Host "Disabling Feedback scheduled tasks..."
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient"

# Disable location-based tasks and map tasks
Write-Host "Disabling location-based scheduled tasks..."
Disable-ScheduledTask -TaskName "Microsoft\Windows\Location\Notifications"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Maps\MapsToastTask"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Maps\MapsUpdateTask"

#---------------------------------------------------------------
# Disable User Account Control.
#---------------------------------------------------------------
Write-Host "Disabling Limited User Account..."
$UACPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-Reg $UACPath "EnableLUA" 0x0 "DWORD"
Set-Reg $UACPath "ConsentPromptBehaviorAdmin" 0x0 "DWORD"


#---------------------------------------------------------------
# Remove Unnecessary app packages and reclaim some disk.
#---------------------------------------------------------------
# Not even Microsoft can properly elaborate on what this does.
Write-Host "Removing Appconnector..."
Get-AppxPackage *Appconnector* | Remove-AppxPackage

# This vaguely named comm app is pretty mysterious, too.
Write-Host "Removing windowscommunicationsapps..."
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage

# Self-explanatory.
Write-Host "Removing all Bing apps..."
Get-AppxPackage *Bing* | Remove-AppxPackage

# Never heard of anyone who used this.
Write-Host "Removing 'Get Started' App..."
Get-AppxPackage *GetStarted* | Remove-AppxPackage

# If you're a fan of web apps handling your map needs,
# you won't need these.
Write-Host "Removing Windows Maps..."
Get-AppxPackage *Microsoft.WindowsMaps* | Remove-AppxPackage

# I never use any of the Xbox apps.
Write-Host "Removing all xbox apps..."
Get-AppxPackage *xbox* | Remove-AppxPackage

# Or the Windows Phone.
Get-AppxPackage *WindowsPhone* | Remove-AppxPackage

# Surely these are here by mistake...
Write-Host "Removing all Zune apps..."
Get-AppxPackage *zune* | Remove-AppxPackage
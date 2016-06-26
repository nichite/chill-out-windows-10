# Chill out, Windows 10.
On a whole, I rather like Window's latest operating system. There are, however, a few tweaks I've
made to make it decidedly more chill.

##Features
### Advertising and Notifications
I've turned off a few things here. First, I've disabled apps from using my Ad ID. I've also taken
the liberty of removing RSS feeds, the notification center, and suggested apps.

### Streamlining Windows Search
I prefer to see only local resources when I search for things. Here, I've disabled Bing, all web
results, location-based suggestions, and Cortana.

### Usage Data and Feedback
I actually haven't disabled any of these on my own machine--I like to send as much usage data
to other developers as possible to help them enhance their products. But I know some people
are very nervous about that sort of thing, so I've turned a lot of it off here.

### User Account Control
I don't like having to confirm every time I use elevated privileges on my personal machine.
If you're working on a business machine and/or are a sysadmin on a large domain, skip this.

### Built-in Apps.
I don't use any of these. So I took them out. If you do, comment these out.

## How to run
Download the PowerShell script and run it in admin mode. IMPORTANT: don't run random scripts off 
the internet unless you know what you're doing, and you've read through the code and verified that 
there's no funny business. After all, I'm just some guy. Comment out the sections you don't want.

You'll likely need to change your script execution policy like so:

```powershell
Set-ExecutionPolicy Unrestricted
Set-Location [location of script]
.\chill-out-windows-10.ps1
```

Enjoy!

-Hite

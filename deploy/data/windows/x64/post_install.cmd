sc stop AmneziaWGTunnel$PotokYou
sc delete AmneziaWGTunnel$PotokYou
taskkill /IM "PotokYou-service.exe" /F
taskkill /IM "PotokYou.exe" /F
exit /b 0

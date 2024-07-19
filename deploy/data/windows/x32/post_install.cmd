sc stop AmneziaWGTunnel$PotokVPN
sc delete AmneziaWGTunnel$PotokVPN
taskkill /IM "PotokVPN-service.exe" /F
taskkill /IM "PotokVPN.exe" /F
exit /b 0

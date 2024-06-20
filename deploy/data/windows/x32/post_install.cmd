sc stop PotokWGTunnel$PotokVPN
sc delete PotokWGTunnel$PotokVPN
taskkill /IM "PotokVPN-service.exe" /F
taskkill /IM "PotokVPN.exe" /F
exit /b 0

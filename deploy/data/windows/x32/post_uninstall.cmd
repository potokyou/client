set AmneziaPath=%~dp0
echo %AmneziaPath%

"%AmneziaPath%\PotokVPN.exe" -c
timeout /t 1
sc stop PotokVPN-service
sc delete PotokVPN-service
sc stop AmneziaWGTunnel$PotokVPN
sc delete AmneziaWGTunnel$PotokVPN
taskkill /IM "PotokVPN-service.exe" /F
taskkill /IM "PotokVPN.exe" /F
exit /b 0

set PotokPath=%~dp0
echo %PotokPath%

"%PotokPath%\PotokVPN.exe" -c
timeout /t 1
sc stop PotokVPN-service
sc delete PotokVPN-service
sc stop PotokWGTunnel$PotokVPN
sc delete PotokWGTunnel$PotokVPN
taskkill /IM "PotokVPN-service.exe" /F
taskkill /IM "PotokVPN.exe" /F
exit /b 0

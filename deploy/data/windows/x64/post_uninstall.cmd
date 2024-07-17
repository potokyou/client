set PotokPath=%~dp0
echo %PotokPath%

"%PotokPath%\PotokYou.exe" -c
timeout /t 1
sc stop PotokYou-service
sc delete PotokYou-service
sc stop AmneziaWGTunnel$PotokYou
sc delete AmneziaWGTunnel$PotokYou
taskkill /IM "PotokYou-service.exe" /F
taskkill /IM "PotokYou.exe" /F
exit /b 0

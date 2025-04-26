# Nombre de archivo único
$outputPath = "$env:temp\wallpaper_$(Get-Random).bmp"

# Descarga con reintentos
for($i=0; $i -lt 3; $i++) {
    try {
        Invoke-WebRequest "https://i.ibb.co/XJSPt9s/1.png" -OutFile $outputPath -ErrorAction Stop
        break
    } catch { 
        Start-Sleep -Seconds 1
        if($i -eq 2) { exit 1 }
    }
}

# Código para cambiar wallpaper (el mismo que antes)
# ...

# Limpieza y forzar actualización
Rundll32.exe user32.dll, UpdatePerUserSystemParameters
Start-Sleep -Seconds 1
Remove-Item $outputPath -Force -ErrorAction SilentlyContinue

# Verificación final
if ((Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name Wallpaper -ErrorAction SilentlyContinue) -like "*$($outputPath.Substring($outputPath.LastIndexOf('\')+1)*") {
    Write-Host "✅ Wallpaper cambiado correctamente" -ForegroundColor Green
} else {
    Write-Host "❌ Error: El cambio no persistió" -ForegroundColor Red
}

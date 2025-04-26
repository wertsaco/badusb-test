# Configuración inicial
$url = "https://i.ibb.co/XJSPt9s/1.png"
$randomName = "wallpaper_" + (Get-Date -Format "yyyyMMddHHmmss")
$outputPath = "$env:temp\$randomName.png"  # Primero descargamos como PNG

# Descargar la imagen
try {
    Invoke-WebRequest -Uri $url -OutFile $outputPath -ErrorAction Stop
    Write-Host "Imagen descargada correctamente en: $outputPath" -ForegroundColor Cyan
} catch {
    Write-Error "Error al descargar la imagen: $_"
    exit 1
}

# Convertir a BMP para mejor compatibilidad
##Add-Type -AssemblyName System.Drawing
##try {
    #$image = [System.Drawing.Image]::FromFile($outputPath)
    #$bmpPath = [System.IO.Path]::ChangeExtension($outputPath, ".bmp")
    #$image.Save($bmpPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
    #$image.Dispose()
    #Remove-Item $outputPath -Force -ErrorAction SilentlyContinue
    #$outputPath = $bmpPath
    #Write-Host "Imagen convertida a BMP: $outputPath" -ForegroundColor Cyan
#} catch {
    #Write-Warning "No se pudo convertir la imagen a BMP, se usará el formato original"
#}

#Cambiar el wallpaper mejorado
try {
    Add-Type -TypeDefinition $wallpaperCode -ErrorAction Stop
    Write-Host "Configurando nuevo wallpaper..." -ForegroundColor Yellow
    
    # Actualizar registro primero
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $outputPath
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value 2
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value 0
    
    # Aplicar cambios
    [Wallpaper]::Set($outputPath)
    Start-Sleep -Seconds 1
    
    # Forzar actualización
    rundll32.exe user32.dll, UpdatePerUserSystemParameters
    Start-Sleep -Seconds 1
    
    Write-Host "¡Wallpaper cambiado con éxito!" -ForegroundColor Green
} catch {
    Write-Error "ERROR AL CAMBIAR WALLPAPER: $_"
    exit 1
}

# Cambiar el wallpaper old
#$signature = @'
#using System;
#using System.Runtime.InteropServices;
#using Microsoft.Win32;

#public class Wallpaper {
    #[DllImport("user32.dll", CharSet = CharSet.Auto)]
    #public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    
    #public static void SetWallpaper(string path) {
       # SystemParametersInfo(0x0014, 0, path, 0x01 | 0x02);
        #// Actualizar también en el registro
       # RegistryKey key = Registry.CurrentUser.OpenSubKey(@"Control Panel\Desktop", true);
      #  key.SetValue(@"WallpaperStyle", "2");  # 2 = Stretched
      #  key.SetValue(@"TileWallpaper", "0");
      #  key.Close();
   # }
#}
'@

try {
    Add-Type -TypeDefinition $signature -ErrorAction Stop
    [Wallpaper]::SetWallpaper($outputPath)
    Write-Host "Wallpaper cambiado exitosamente!" -ForegroundColor Green
    
    # Forzar actualización del sistema
    #Start-Sleep -Seconds 1
    #rundll32.exe user32.dll, UpdatePerUserSystemParameters
} catch {
    Write-Error "Error al cambiar el wallpaper: $_"
    exit 1
}

# Limpieza opcional (comentar si quieres conservar la imagen)
#try {
    #Remove-Item $outputPath -Force -ErrorAction SilentlyContinue
#} catch {
    #Write-Warning "No se pudo eliminar el archivo temporal: $outputPath"
#}

# Mantener el script abierto para ver errores
Write-Host "`nOperación completada. Presiona Enter para salir..." -ForegroundColor Yellow
Read-Host

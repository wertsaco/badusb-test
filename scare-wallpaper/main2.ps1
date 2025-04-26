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
# Cambiar el wallpaper
$signature = @'
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    
    public static void SetWallpaper(string path) {
        SystemParametersInfo(0x0014, 0, path, 0x01 | 0x02);
        // Actualizar también en el registro
        RegistryKey key = Registry.CurrentUser.OpenSubKey(@"Control Panel\Desktop", true);
        key.SetValue(@"WallpaperStyle", "2");
        key.SetValue(@"TileWallpaper", "0");
        key.Close();
    }
}
'@

try {
    Add-Type -TypeDefinition $signature -ErrorAction Stop
    [Wallpaper]::SetWallpaper($outputPath)
    Write-Host "Wallpaper cambiado exitosamente!" -ForegroundColor Green
} catch {
    Write-Error "Error al cambiar el wallpaper: $_"
    exit 1
}

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

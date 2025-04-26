$url = "https://i.ibb.co/XJSPt9s/1.png"
$outputPath = "$env:temp\img.bmp"  # Cambiado a BMP para mejor compatibilidad

# Descargar la imagen
try {
    Invoke-WebRequest -Uri $url -OutFile $outputPath -ErrorAction Stop
} catch {
    Write-Error "Error al descargar la imagen: $_"
    exit 1
}

# Convertir a BMP si es necesario (opcional)
Add-Type -AssemblyName System.Drawing
try {
    $image = [System.Drawing.Image]::FromFile($outputPath)
    $newPath = [System.IO.Path]::ChangeExtension($outputPath, ".bmp")
    $image.Save($newPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
    $image.Dispose()
    $outputPath = $newPath
} catch {
    Write-Warning "No se pudo convertir la imagen, usando formato original"
}

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

# Cerrar la ventana inmediatamente
Stop-Process -Id $PID -Force

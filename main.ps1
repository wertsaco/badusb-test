# Versión modificada sin comentario multilínea
# CONSOLE QR CODE GENERATOR
# Generates QR codes using goqr.me API and displays them in console

# Parámetros predefinidos (modifica estos valores)
$URL = "https://www.tiktok.com/@aglesmoto"  # Texto/URL para el QR
$highC = "y"                  # "y" o "n"
$inverse = "y"                # "y" o "n"

# Set console
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Console]::BackgroundColor = "Black"

try {
    $wshell = New-Object -ComObject wscript.shell 
    $wshell.AppActivate("Powershell.exe")
    $wshell.SendKeys("{F11}")
}
catch {
    Write-Warning "Could not switch to full screen mode"
}

Clear-Host

function Generate-QRCodeURL {
    param (
        [string]$URL,
        [int]$size = 100
    )
    $EncodedURL = [uri]::EscapeDataString($URL)
    return "https://api.qrserver.com/v1/create-qr-code/?size=${size}x${size}&data=$EncodedURL"
}

function Download-QRCodeImage {
    param ([string]$QRCodeURL)
    $TempFile = [System.IO.Path]::GetTempFileName() + ".png"
    try {
        Invoke-WebRequest -Uri $QRCodeURL -OutFile $TempFile
        return $TempFile
    }
    catch {
        Write-Error "Failed to download QR code image: $_"
        exit 1
    }
}

# Generate and download QR code
$QRCodeURL = Generate-QRCodeURL -URL $URL
$QRCodeImageFile = Download-QRCodeImage -QRCodeURL $QRCodeURL

# Load the image
try {
    $QRCodeImage = [System.Drawing.Image]::FromFile($QRCodeImageFile)
    $Bitmap = New-Object System.Drawing.Bitmap($QRCodeImage)
}
catch {
    Write-Error "Failed to load QR code image: $_"
    exit 1
}

# Set character mapping
$Chars = switch ($true) {
    ($highC -eq 'n' -and $inverse -eq 'y') { @('░', '█'); break }
    ($highC -eq 'n' -and $inverse -eq 'n') { @('█', '░'); break }
    ($highC -eq 'y' -and $inverse -eq 'y') { @(' ', '█'); break }
    ($highC -eq 'y' -and $inverse -eq 'n') { @('█', ' '); break }
    default { @('█', ' ') }
}

# Display QR code in console
for ($y = 0; $y -lt $Bitmap.Height; $y += 2) {
    for ($x = 0; $x -lt $Bitmap.Width; $x++) {
        $Index = if ($Bitmap.GetPixel($x, $y).ToArgb() -eq -16777216) { 1 } else { 0 }
        Write-Host -NoNewline $Chars[$Index]
    }
    Write-Host
}

# Clean up
$QRCodeImage.Dispose()
Remove-Item -Path $QRCodeImageFile -Force -ErrorAction SilentlyContinue

Pause

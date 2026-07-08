Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $root "assets\brand\mindspace_logo.png"

function Save-Icon {
    param(
        [string] $Destination,
        [int] $Size
    )

    $source = [System.Drawing.Image]::FromFile($sourcePath)
    $bitmap = New-Object System.Drawing.Bitmap $Size, $Size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.Clear([System.Drawing.Color]::White)
    $graphics.DrawImage($source, 0, 0, $Size, $Size)

    $directory = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $bitmap.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)

    $graphics.Dispose()
    $bitmap.Dispose()
    $source.Dispose()
}

$androidIcons = @{
    "android\app\src\main\res\mipmap-mdpi\ic_launcher.png" = 48
    "android\app\src\main\res\mipmap-hdpi\ic_launcher.png" = 72
    "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" = 96
    "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" = 144
    "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" = 192
}

$iosIcons = @{
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@1x.png" = 20
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@2x.png" = 40
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@3x.png" = 60
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@1x.png" = 29
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@2x.png" = 58
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@3x.png" = 87
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@1x.png" = 40
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@2x.png" = 80
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@3x.png" = 120
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@2x.png" = 120
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@3x.png" = 180
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@1x.png" = 76
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@2x.png" = 152
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-83.5x83.5@2x.png" = 167
    "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png" = 1024
}

foreach ($icon in $androidIcons.GetEnumerator()) {
    Save-Icon -Destination (Join-Path $root $icon.Key) -Size $icon.Value
}

foreach ($icon in $iosIcons.GetEnumerator()) {
    Save-Icon -Destination (Join-Path $root $icon.Key) -Size $icon.Value
}

Write-Host "MindSpace launcher icons generated."

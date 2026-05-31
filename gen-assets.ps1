# Generates Android launcher icons + splash screens from a source logo using GDI+.
# Re-renders each existing resource PNG at its own current dimensions, so we never
# have to hardcode per-density sizes. No external downloads / native deps required.

Add-Type -AssemblyName System.Drawing

$src   = "C:\Users\joshu\.cursor\projects\c-Users-joshu-projects-odds-trader\assets\icon.png"
$resBase = Join-Path $PSScriptRoot "android\app\src\main\res"

$top    = [System.Drawing.Color]::FromArgb(255, 23, 99, 214)   # #1763d6
$bottom = [System.Drawing.Color]::FromArgb(255, 10, 61, 145)   # #0a3d91

$source = [System.Drawing.Image]::FromFile($src)

function New-Canvas([int]$w, [int]$h) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = "AntiAlias"
  $g.InterpolationMode = "HighQualityBicubic"
  $g.PixelOffsetMode = "HighQuality"
  $rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $top, $bottom, 45.0)
  $g.FillRectangle($brush, $rect)
  $brush.Dispose()
  return @{ bmp = $bmp; g = $g }
}

# Draw the source image scaled to COVER the whole canvas (crops overflow), centered.
function Draw-Cover($g, [int]$w, [int]$h) {
  $scale = [Math]::Max($w / $source.Width, $h / $source.Height)
  $dw = [int]($source.Width * $scale)
  $dh = [int]($source.Height * $scale)
  $x = [int](($w - $dw) / 2)
  $y = [int](($h - $dh) / 2)
  $g.DrawImage($source, $x, $y, $dw, $dh)
}

# Draw the source image CONTAINED at a fraction of the canvas, centered (for splash).
function Draw-Centered($g, [int]$w, [int]$h, [double]$frac) {
  $target = [Math]::Min($w, $h) * $frac
  $scale = $target / [Math]::Max($source.Width, $source.Height)
  $dw = [int]($source.Width * $scale)
  $dh = [int]($source.Height * $scale)
  $x = [int](($w - $dw) / 2)
  $y = [int](($h - $dh) / 2)
  $g.DrawImage($source, $x, $y, $dw, $dh)
}

function Save-Png($obj, [string]$path) {
  $obj.bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $obj.g.Dispose(); $obj.bmp.Dispose()
}

$icons = 0; $splashes = 0

# Launcher icons (square + round + adaptive foreground): cover render.
Get-ChildItem -Path $resBase -Recurse -Include "ic_launcher.png","ic_launcher_round.png","ic_launcher_foreground.png" |
  ForEach-Object {
    $img = [System.Drawing.Image]::FromFile($_.FullName)
    $w = $img.Width; $h = $img.Height; $img.Dispose()
    $c = New-Canvas $w $h
    Draw-Cover $c.g $w $h
    Save-Png $c $_.FullName
    $icons++
  }

# Splash screens: brand gradient with centered logo.
Get-ChildItem -Path $resBase -Recurse -Include "splash.png" |
  ForEach-Object {
    $img = [System.Drawing.Image]::FromFile($_.FullName)
    $w = $img.Width; $h = $img.Height; $img.Dispose()
    $c = New-Canvas $w $h
    Draw-Centered $c.g $w $h 0.32
    Save-Png $c $_.FullName
    $splashes++
  }

# Master 1024 icon + 2732 splash for iOS (used by Xcode build on macOS).
$assets = Join-Path $PSScriptRoot "assets"
New-Item -ItemType Directory -Force -Path $assets | Out-Null
$ic = New-Canvas 1024 1024; Draw-Cover $ic.g 1024 1024; Save-Png $ic (Join-Path $assets "icon.png")
$sp = New-Canvas 2732 2732; Draw-Centered $sp.g 2732 2732 0.30; Save-Png $sp (Join-Path $assets "splash.png")
$spd = New-Canvas 2732 2732; Draw-Centered $spd.g 2732 2732 0.30; Save-Png $spd (Join-Path $assets "splash-dark.png")

$source.Dispose()
Write-Output "Updated $icons launcher icons and $splashes splash images; wrote master assets."

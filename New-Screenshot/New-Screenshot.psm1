<# 
 .Synopsis
  Saves a screenshot to a file.

 .Description
  Saves a screenshot to a file.

 .Example
   # Takes a screenshot of the primary display
   New-Screenshot
   
 .Link
   GitHub: https://github.com/BWoodson/New-Screenshot
#>
function New-Screenshot
{
  $psv = $PSVersionTable.PSVersion

  # Using .Net to create a screenshot
  if ($psv.Major -lt 3) {
    # This has been depricated past v2
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing")
  } else {
    Add-Type -AssemblyName System.Drawing
  }

  # The current datetime
  $date = Get-Date -Format yyyyMMddHHmmss

  # Temporarily saving to the users destop
  $profile_path = $env:USERPROFILE
  $pictures_path = "$profile_path\Pictures"

  # Only handling the primary screen for now
  Add-Type -AssemblyName System.Windows.Forms
  $primary_screen = [System.Windows.Forms.Screen]::AllScreens | Where-Object { $_.Primary -eq $true }

  $screen_height = $primary_screen.Bounds.Height
  $screen_width = $primary_screen.Bounds.Width

  $bounds = [Drawing.Rectangle]::FromLTRB(0, 0, $screen_width, $screen_height)
  $file_path = "$pictures_path\screenshot-$date.png"
    
  $image = New-Object Drawing.Bitmap $bounds.width, $bounds.height
  $graphics = [Drawing.Graphics]::FromImage($image)

  $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)

  $image.Save($file_path)

  If(Test-Path $file_path) {
    Write-Host "Saved: $file_path"
  } else {
    Write-Host "Error saving: $file_path"
  }

  $graphics.Dispose()
  $image.Dispose()
}
export-modulemember -function New-Screenshot
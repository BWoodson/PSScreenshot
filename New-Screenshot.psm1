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
   # Using .Net to create a screenshot. Based on:
   # https://stackoverflow.com/questions/2969321/how-can-i-do-a-screen-capture-in-windows-powershell
   [Reflection.Assembly]::LoadWithPartialName("System.Drawing")
   
   # The current datetime
   $date = Get-Date -Format yyyyMMddHHmmss
   
   # Temporarily saving to the users destop
   $profile_path = $env:USERPROFILE
   $path = "$profile_path\Desktop"
   
   # Only handling the primary screen for now
   Add-Type -AssemblyName System.Windows.Forms
   $primary_screen = [System.Windows.Forms.Screen]::AllScreens | Where-Object { $_.Primary -eq $true }
   
   $screen_height = $primary_screen.Bounds.Height
   $screen_width = $primary_screen.Bounds.Width
   
   $bounds = [Drawing.Rectangle]::FromLTRB(0, 0, $screen_width, $screen_height)
   $file_path = "$path\screenshot-$date.png"
      
   $image = New-Object Drawing.Bitmap $bounds.width, $bounds.height
   $graphics = [Drawing.Graphics]::FromImage($image)
   
   $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
   
   $image.Save($file_path)
   
   $graphics.Dispose()
   $image.Dispose()
}
export-modulemember -function New-Screenshot
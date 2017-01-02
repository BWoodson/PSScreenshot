<# 
  .Synopsis
  Saves a screenshot to a file.

  .Description
  Saves a screenshot to a file.

  .Example
  # Take a screenshot of the primary display
  Save-Screenshot

  .Example
  # Take 10 screenshots 30 seconds apart in a specific folder
  Save-Screenshot -Folder C:\Temp -Delay 30 -Frames 10

  .Link
  GitHub: https://github.com/BWoodson/PSScreenshot
#>
function Save-Screenshot
{
  Param (
    [String] $Folder = '',
    [int] $Delay = 0,
    [int] $Frames = 1
  )

  $psv = $PSVersionTable.PSVersion

  # Using .Net to create a screenshot
  if ($psv.Major -lt 3) {
    # This has been depricated past v2
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing")
  } else {
    Add-Type -AssemblyName System.Drawing
  }

  for ($i = 0; $i -lt $Frames; $i++) {
    # The current datetime
    $date = Get-Date -Format yyyyMMddHHmmss

    Start-Sleep -Seconds $Delay

    if ($Folder -eq '') {
      $userPath = $env:USERPROFILE
      $picturesPath = "$userPath\Pictures"
      $Folder = $picturesPath
    } else {
      if ( !(Test-Path($Folder))) {
        Write-Error "Folder: '$Folder' does not exist"
        Break
      }
    }

    # Only handling the primary screen for now
    Add-Type -AssemblyName System.Windows.Forms
    $primaryScreen = [System.Windows.Forms.Screen]::AllScreens | Where-Object { $_.Primary -eq $TRUE }
    
    $display = Get-WmiObject -Class "Win32_VideoController"

    #$screenHeight = $primaryScreen.WorkingArea.Height
    #$screenWidth = $primaryScreen.WorkingArea.Width
    
    $screenHeight = $display.CurrentVerticalResolution
    $screenWidth = $display.CurrentHorizontalResolution
    
    #write-error ("h: " + $screenHeight)
    #write-error ("wah: " + $primaryScreen.workingarea.height)

    $bounds = [Drawing.Rectangle]::FromLTRB(0, 0, $screenWidth, $screenHeight)
    $filePath = "$Folder\screenshot-$date.png"
      
    $image = New-Object Drawing.Bitmap $bounds.width, $bounds.height
    $graphics = [Drawing.Graphics]::FromImage($image)

    $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)

    $image.Save($filePath)

    If(Test-Path $filePath) {
      Write-Information -MessageData "Saved: $filePath"
    } else {
      Write-Error -MessageData "Error saving: $filePath"
    }

    $graphics.Dispose()
    $image.Dispose()
  }
}
export-modulemember -function Save-Screenshot
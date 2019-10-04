Function Add-PSGUIActions {
    param($xamlpath, $control, [bool]$EDITORMODE)
    # $global:btntemp = ""
    $xamlpath = Get-Item -Path $xamlpath
    [xml]$xaml = Get-Content -Path $xamlpath
    $FileRootFolder = $xamlpath.Directory | Split-path

    IF (!($EDITORMODE)) {
        .  $FileRootFolder\GUIScripts\$($xamlpath.BaseName)-guiscripts.ps1
    }

    
    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        Set-Variable -Name ($_.Name) -Value $control.FindName($_.Name) -Scope Global
             
        IF ($_.Tag -ne $null) {
            $name = $_.Name
            $_.Tag -split ',' | ForEach-Object {
                $tag = ($_).Trim()
        
                $btntemp = $xamlpath.BaseName + "_" + $name + "_" + $tag
                #  write-psfmessage "Registering Action $btntemp"
             
                # Load all available buttons, and execute via external script file
                IF ($EDITORMODE) {

                    $action2 = @'
param ([object]$Sender, [Object]$e)
$actionname = $e.RoutedEvent.Name 

'@


                    $action2 += @"
write-psfmessage "Viewing $btntemp"
& "$FileRootFolder\GUIScripts\Editor\$btntemp.ps1"
"@

                    #aasdf
                    $scriptblock = [scriptblock]::Create($action2)
                    write-psfmessage "Editor Mode Enabled - $name - $Tag"
                    (Get-Variable -Name $name).Value.$("Add_$tag")($scriptblock)
                    IF (!(Test-Path $FileRootFolder\GUIScripts\Editor\$btntemp.ps1)) {
                        new-item $FileRootFolder\GUIScripts\Editor\$btntemp.ps1 -force
                    }
                        
                }
                    
                ELSE {
                    
                    (Get-Variable -Name $name).Value.$("Add_$tag")($((Get-Variable -Name $btntemp).Value))
                    
    
                } #TAG SPLIT FOREACH END
            } # IF TAG END

        }
    }
}
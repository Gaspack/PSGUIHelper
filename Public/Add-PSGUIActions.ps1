Function Add-PSGUIActions {
    <#
        .SYNOPSIS
        Reads the XAML File Content
        
        .PARAMETER XAMLfile
        Path of the WPF XAML file
        
        
        .EXAMPLE
        Read-PSGUIXaml -XAMLFile "test.xaml" 
        
    #>  
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_ })]
        [string]$XAMLfile, 

        [Parameter(Position = 1, Mandatory = $true)]
        $control, 

        [Parameter(Position = 2)]
        [bool]$EditorMode = $False
         
    )

    begin {
        $xamlpath = Get-Item -Path $XAMLfile
        [xml]$xaml = Get-Content -Path $XAMLfile
        $FileRootFolder = $xamlpath.Directory | Split-path

        IF (!($EDITORMODE)) {
            .  $FileRootFolder\GUIScripts\$($xamlpath.BaseName)-guiscripts.ps1
        }
    }
    
    process {
        $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
            Set-Variable -Name ($_.Name) -Value $control.FindName($_.Name) -Scope Global
             
            IF ($_.Tag -ne $null) {
                $name = $_.Name
                $_.Tag -split ',' | ForEach-Object {
                    $tag = ($_).Trim()
        
                    $btntemp = $xamlpath.BaseName + "_" + $name + "_" + $tag
                    write-psfmessage "Registering Action $btntemp"
             
                    # Load all available buttons, and execute via external script file
                    IF ($EDITORMODE) {

                        $action2 = @'
param ([object]$Sender, [Object]$e)
$actionname = $e.RoutedEvent.Name 

'@


                        $action2 += @"
    write-psfmessage "Viewing $btntemp"
    & "$FileRootFolder\GUIScripts\$($xamlpath.BaseName)\$btntemp.ps1"
"@

                        $scriptblock = [scriptblock]::Create($action2)
                        write-psfmessage "Editor Mode Enabled - $name - $Tag" -tag $Tag -verbose
                        Try {
                            (Get-Variable -Name $name).Value.$("Add_$tag")($scriptblock)
                        }
                        Catch {
                            Write-PSFMessage -Level Warning -Message "ERROR: " -ErrorRecord $_ -verbose
                        }
                            IF (!(Test-Path $FileRootFolder\GUIScripts\$($xamlpath.BaseName)\$btntemp.ps1)) {
                            new-item $FileRootFolder\GUIScripts\$($xamlpath.BaseName)\$btntemp.ps1 -force
                        }
                        
                    }
                    
                    ELSE {
                    
                        (Get-Variable -Name $name).Value.$("Add_$tag")($((Get-Variable -Name $btntemp).Value))
                    
    
                    } #END ELSE
                } # END Tag Split

            } # IF TAG END
        } # END XAML Node
    } # END PROCESS

    end { }
}
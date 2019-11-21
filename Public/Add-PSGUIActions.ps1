Function Add-PSGUIActions {
    <#
        .SYNOPSIS
        Adds Actions to Controls
        
        .PARAMETER XAMLfile
        Path of the WPF XAML file
        
        .PARAMETER Control
        Sets the control in question

        .PARAMETER EditorMode
        Allows live editing of control actions        
        
        .EXAMPLE
        Add-PSGUIActions -XAMLFile "test.xaml" -Control $Control -EditorMode $false
        
    #> 
    [CmdletBinding()]
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
                    Write-Verbose "Registering Action $btntemp"
             
                    # Load all available buttons, and execute via external script file
                    IF ($EDITORMODE) {

                        $action2 = @'
param ([object]$Sender, [Object]$e)
$actionname = $e.RoutedEvent.Name 

'@


                        $action2 += @"
    Write-Verbose "Viewing $btntemp"
    & "$FileRootFolder\GUIScripts\$($xamlpath.BaseName)\$btntemp.ps1"
"@

                        $scriptblock = [scriptblock]::Create($action2)
                        Write-Verbose "Editor Mode Enabled - $name - $Tag" 
                        Try {
                            (Get-Variable -Name $name).Value.$("Add_$tag")($scriptblock)
                        }
                        Catch {
                            Write-Verbose "ERROR: "
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
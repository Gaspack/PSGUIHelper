
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
Function Export-PSGUIScripts {
    param($xamlpath)
    #$xamlpath = "H:\Documents\PS\GUIH-WPF\GAT20\GUIViews\GAT10.xaml"
    $xamlpath = Get-Item -Path $xamlpath
    [xml]$xaml = Get-Content -Path  $xamlpath
    $FileRootFolder = $xamlpath.Directory  | Split-path
    
    $action2 = ""
    
    $xaml.SelectNodes("//*[@Name]") | Select-Object Name, Tag | Where-Object {$_.Tag -ne $null}  | ForEach-Object {
        $name = $_.Name
        $_.Tag -split ',' | ForEach-Object {
            
                $tag = ($_).Trim()
        $btntemp = $xamlpath.BaseName + "_" + $Name + "_" + $tag
        Write-PSFMessage -Level Verbose "Exporting Script"
        $filepath = $(Join-Path -Path "$FileRootFolder\GUIScripts\Editor" -ChildPath "$btntemp.ps1")
        IF (TEST-path $filepath) {
            $action2 += "`$$btntemp = `{`r`n"
            $action2 += 'param ([object]$Sender, [Object]$e)' + "`r`n`r`n"
            $action2 += [IO.File]::ReadAllText($filepath) +  "`r`n"
            $action2 += "`}`r`n`n" 
        }
    }
    
}
    $action2 | Out-File "$FileRootFolder\GUIScripts\$($xamlpath.BaseName)-guiscripts.ps1" -Encoding UTF8 -force

}


Function New-PSGUIWPF {
    [CmdletBinding()]
    param($xamlfile, [bool]$EDITORMODE, $DataContext, $ScriptRootFolder)
  
    #modifydate = Sunday, May 26, 2019 6:37:13 PM
    $xamlfile = Get-Item -Path $xamlfile
    $FileRootFolder = $xamlfile.Directory  | Split-path
    #region Add required assemblies
    Write-PSFMessage -Level Verbose "Loading Assembly"
    Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration, System.ComponentModel, System.Data, WindowsBase, System.Data, System.Collections

    [System.Reflection.Assembly]::LoadFrom("$PSScriptroot\assembly\MahApps.Metro.dll") | Out-Null
    [System.Reflection.Assembly]::LoadFrom("$PSScriptroot\assembly\MahApps.Metro.IconPacks.dll") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    #endregion required assemblies

    #region XAML Main Window
   # $Global:Window = Read-PSGUIXaml -xaml $ScriptRootFolder\GUIViews\$xamlfile.xaml
    $Global:Window = Read-PSGUIXaml -xaml $xamlfile

    IF ($EDITORMODE) {
        $Window.Title += " - Editor Mode Enabled"
    }


    #Add-PSGUIActions -xamlpath $ScriptRootFolder\GUIViews\$xamlfile.xaml -Control $Window -Editormode $EDITORMODE
    Add-PSGUIActions -xamlpath $xamlfile -Control $Window -Editormode $EDITORMODE
    #endregion XAML Main Window

    #region Custom Buttons
    $custombuttonpath = "$ScriptRootFolder\GUIScripts\$xamlfile" + "_" + "custombuttons.ps1"
    IF (Test-Path $custombuttonpath) {
        & "$custombuttonpath" 
    
    }
    #endregion Custom Buttons

    #region Setup DataContext 
        
    $Window.DataContext = $DataContext 
    #endregion Setup DataContext


    
    #region RUN APP        
    IF ($PSVersionTable.PSVersion.Major -gt 4) {
        Write-PSFMessage -Level Verbose "Using PS5 Window Loading (Application Run) - $env:username"
        #$null = $Window.ShowDialog()
        $app = [Windows.Application]::New()
        $null = $app.Run($Window)
        # Force garbage collection just to start slightly lower RAM usage.
        [System.GC]::Collect()

    }
    ELSE {
   
        Write-PSFMessage -Level Verbose "Using PS3 Window Loading (ShowDialog)"
        $null = $Window.ShowDialog() 
    }
    #endregion RUN APP

    IF ($output -ne "") {
        $output
    }
}

function Read-PSGUIXaml {
[CmdletBinding()]
param($xaml)
    $xamlfile = Get-Item -Path $xaml
    $FileRootFolder = $xamlfile.Directory  | Split-path
 Write-PSFMessage -Level Verbose "Loading XAML $xaml  - $FileRootFolder"

    $xamlContent = Get-Content -Path $xamlfile -raw

    [xml]$xamlxml = $xamlContent.Replace('{0}', $FileRootFolder)
	$xamlReader = New-Object System.Xml.XmlNodeReader $xamlxml

	[Windows.Markup.XamlReader]::Load($xamlReader)
}
Function Update-PSGUIWPF {
    param($xaml, $control, $editormode)


    ### CHange XAML Views

    Write-PSFMessage -Level Verbose "Updating $xaml View"
    $ScriptRootFolder = Get-PSFConfigValue -fullName "gat10.ScriptRootFolder"
    $xamlpath = "H:\Documents\PS\GUIH-WPF\GAT30\GUIViews\$xaml.xaml"
    IF (Test-Path -Path $xamlpath) {
        
        $xaml = Read-PSGUIXaml $xamlpath
        
    }
    ELSE {
        $xamlpath = "$ScriptRootFolder\GUIViews\Generic.xaml"
        $xaml = Read-PSGUIXaml $xamlpath
        
    }
    
    $ContentControl.Content = $xaml
    Add-PSGUIActions -xamlpath $xamlpath -Control $ContentControl.Content -Editormode $true
}




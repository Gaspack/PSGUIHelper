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


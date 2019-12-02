Function Export-PSGUIScripts {
    [CmdletBinding()]
    param(
        [ValidateScript({Test-Path $_})]
        [string]$xamlpath,
        $outpath)

    Begin {
        $xamlpath2 = get-item $xamlpath
        [xml]$xaml = Get-Content -Path $xamlpath
    
        $FileRootFolder = $xamlpath2.Directory  | Split-path
        $basename = $xamlpath2.BaseName
        write-verbose "$xamlpath - $basename - $FileRootFolder"
    }

    Process {
        $xaml.SelectNodes("//*[@Name]") | Select-Object Name, Tag | Where-Object {$_.Tag -ne $null}  | ForEach-Object {
            $name = $_.Name
            $_.Tag -split ',' | ForEach-Object {
                
                    $tag = ($_).Trim()
            $btntemp = $BaseName + "_" + $Name + "_" + $tag
            
            Write-Verbose "Exporting Script" 
            $filepath = $(Join-Path -Path "$FileRootFolder\GUIScripts\$basename" -ChildPath "$btntemp.ps1")
            write-verbose $filepath
            IF (TEST-path $filepath) {
                $action2 += "`$$btntemp = `{`r`n"
                $action2 += 'param ([object]$Sender, [Object]$e)' + "`r`n`r`n"
                $action2 += [IO.File]::ReadAllText($filepath) +  "`r`n"
                $action2 += "`}`r`n`n" 
            }
        }
        
    }
    }




End {
    $action2 | Out-File "$outpath\$basename-guiscripts.ps1" -Encoding UTF8 -force
    Write-Verbose "Folder Root - $outpath\$basename-guiscripts.ps1)"
}
}

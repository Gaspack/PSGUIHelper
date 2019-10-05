Function Update-PSGUIWPF {
    <#
        .SYNOPSIS
        Reads the XAML File Content
        
        .PARAMETER XAMLfile
        Path of the WPF XAML file
        
        
        .EXAMPLE
        Read-PSGUIXaml -XAMLFile "test.xaml" 
        
    #>
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$XAMLfile, 
        [Parameter(Position = 1, Mandatory = $false)]
        $ControlName, 
        [Parameter(Position = 2)]
        [bool]$EditorMode = $False
         
    )

    begin {
    }

    ### CHange XAML Views
    process {
        $xaml = Read-PSGUIXaml -XAMLfile $XAMLfile

        (get-variable -Name "$ControlName").Value.Content =  $xaml
        Add-PSGUIActions -XAMLfile $xamlpath -Control $ContentControl.Content -Editormode $EDITORMODE
    }

    end {
        Write-PSFMessage -Level Verbose $xamlpath
    }

}



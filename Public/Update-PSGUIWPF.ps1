Function Update-PSGUIWPF {
    <#
        .SYNOPSIS
        Updates WPF Control in a dynamic way
        
        .PARAMETER XAMLfile
        Path of the WPF XAML file
        
        .PARAMETER ControlName
        Target the Control to be updated
        
        .EXAMPLE
        Update-PSGUIWPF -XAMLFile "test.xaml"  -ControlMame $control
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateScript({Test-Path $_})]
        [string]$XAMLfile, 
        [Parameter(Position = 1, Mandatory = $True)]
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
        $control = (get-variable -Name "$ControlName").Value.Content
        Add-PSGUIActions -XAMLfile $xamlpath -Control $control -Editormode $EDITORMODE
    }

    end {
        Write-Verbose $xamlpath
    }

}



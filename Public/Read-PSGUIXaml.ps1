function Read-PSGUIXaml {
    <#
        .SYNOPSIS
        Reads the XAML File Content
        
        .PARAMETER XAMLfile
        Path of the WPF XAML file
        
        .EXAMPLE
        Read-PSGUIXaml -XAMLFile "test.xaml" 
        
    #>
    [CmdletBinding()]
    param(        
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_ })]
        [string]$XAMLfile
    )

    Write-Verbose "Loading XAML $xaml  - $FileRootFolder"

    $xamlContent = Get-Content -Path $XAMLfile -raw

    [xml]$xamlxml = $xamlContent.Replace('{0}', $((Get-Item -Path $XAMLfile).Directory | Split-path))
    $xamlReader = New-Object System.Xml.XmlNodeReader $xamlxml

    [Windows.Markup.XamlReader]::Load($xamlReader)
}
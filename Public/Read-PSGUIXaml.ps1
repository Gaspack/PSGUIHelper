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
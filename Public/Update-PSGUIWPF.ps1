Function Update-PSGUIWPF {
    param($xaml, $control, $editormode)


    ### CHange XAML Views

    Write-PSFMessage -Level Verbose "Updating $xaml View"
    $#ScriptRootFolder = Get-PSFConfigValue -fullName "gat10.ScriptRootFolder"
    $xamlpath = "H:\Documents\PS\GUIH-WPF\GAT30\GUIViews\$xaml.xaml"
    IF (Test-Path -Path $xamlpath) {
        
        $xaml = Read-PSGUIXaml $xamlpath
        
    }
    ELSE {
        $xamlpath = "$ScriptRootFolder\GUIViews\Generic.xaml"
        $xaml = Read-PSGUIXaml $xamlpath
        
    }
    
    $ContentControl.Content = $xaml
    Add-PSGUIActions -xamlpath $xamlpath -Control $ContentControl.Content -Editormode $EDITORMODE
}



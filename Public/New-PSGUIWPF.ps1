Function New-PSGUIWPF {

    <#
        .SYNOPSIS
        Start the WPF application

        .Description

        To add actions to controls, add the "Tag" to each control, the powershell script will take care of creating *.ps1 files in the "GUIScripts" folder
        <Button Name="btnHello" Tag="Click" />

        .PARAMETER XAMLfile
        Path of the WPF XAML file
        
        .PARAMETER EditorMode
        To edit your GUI WPF scripts live without closing the GUI
        
        .EXAMPLE
        New-PSGUIWPF -XAMLFile "test.xaml" 

        .EXAMPLE
        To auto create button event ps1 files, use the Tag parameter with the available control event handlers.
        Files are created in GUIScripts folder parent to the xaml file folder.

        New-PSGUIWPF -XAMLFile "text.xaml" -EditorMode $true

    #>
[CmdletBinding()]

    param(
        [Parameter(Position=0,Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$XAMLfile, 

        [Parameter(Position=1)]
        [ValidateSet('True', 'False')]
        [bool]$EditorMode=$False,
        [bool]$HideConsole=$True,
        $DataContext, 
        $ScriptRootFolder
        )
  
    $xamlfile = Get-Item -Path $xamlfile

    #region Add required assemblies
    Write-Verbose "Loading Assembly"

    [System.Windows.Forms.Application]::EnableVisualStyles()
    #endregion required assemblies

    #region XAML Main Window

    $Global:Window = Read-PSGUIXaml -XAMLfile $xamlfile

    IF ($EDITORMODE) {
        $Window.Title += " - Editor Mode Enabled"
    }
    IF ($HideConsole){
        Hide-Console
    }

    Add-PSGUIActions -XAMLfile $xamlfile -Control $Window -Editormode $EDITORMODE
    #endregion XAML Main Window


    #region Setup DataContext 
        
    $Window.DataContext = $DataContext 
    #endregion Setup DataContext

    # If code is running in ISE, use ShowDialog()...
    if ($psISE -or $isCode) {
        $null = $Window.ShowDialog()
        # ...otherwise run as an application
    }
    Else {

 
        $app = [Windows.Application]::New()
        $null = $app.Run($Window)
        #$null = $Window.ShowDialog()
        # Force garbage collection just to start slightly lower RAM usage.
        [System.GC]::Collect()
    }
    #endregion RUN APP

    IF ($output -ne "") {
        $output
    }
}

Function New-PSGUIWPF {
    <#
        .SYNOPSIS
        Start the WPF application
        
        .PARAMETER XAMLfile
        Path of the WPF XAML file
        
        .PARAMETER EditorMode
        To edit your GUI WPF scripts live without closing the GUI
        
        .EXAMPLE
        New-PSGUIWPF -XAMLFile "test.xaml" 
        
        .EXAMPLE 
        Get-ChocoConfig -ConfigurationItem proxy
        
    #>
[CmdletBinding()]

    param(
        [Parameter(Position=0,Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$XAMLfile, 

        [Parameter(Position=1)]
        [ValidateSet('True', 'False')]
        [bool]$EditorMode=$False, 
        $DataContext, 
        $ScriptRootFolder
        )
  
    $xamlfile = Get-Item -Path $xamlfile

    #region Add required assemblies
    Write-PSFMessage -Level Verbose "Loading Assembly"

    [System.Windows.Forms.Application]::EnableVisualStyles()
    #endregion required assemblies

    #region XAML Main Window

    $Global:Window = Read-PSGUIXaml -XAMLfile $xamlfile

    IF ($EDITORMODE) {
        $Window.Title += " - Editor Mode Enabled"
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
        # Make PowerShell Disappear
        $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);' 
        $asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru -ErrorAction Ignore
        $null = $asyncwindow::ShowWindowAsync((get-process -name cmd | Where-Object MainWindowTitle -eq 'GUILauncher').MainWindowHandle, 0)

        #$app = [Windows.Application]::New()
        #$null = $app.Run($Window)
        $null = $Window.ShowDialog()
        # Force garbage collection just to start slightly lower RAM usage.
        [System.GC]::Collect()
    }
    #endregion RUN APP

    IF ($output -ne "") {
        $output
    }
}

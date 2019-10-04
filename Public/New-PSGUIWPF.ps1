Function New-PSGUIWPF {
    [CmdletBinding()]
    param($xamlfile, [bool]$EDITORMODE, $DataContext, $ScriptRootFolder)
  
    #modifydate = Sunday, May 26, 2019 6:37:13 PM
    $xamlfile = Get-Item -Path $xamlfile
    $FileRootFolder = $xamlfile.Directory  | Split-path
    #region Add required assemblies
    Write-PSFMessage -Level Verbose "Loading Assembly"
    #Add-Type -AssemblyName PresentationFramework, System.Drawing, WindowsFormsIntegration, System.ComponentModel, System.Data, WindowsBase, System.Data, System.Collections

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

    # If code is running in ISE, use ShowDialog()...
if ($psISE -or $isCode)
{
   $null = $Window.ShowDialog()
# ...otherwise run as an application
}
Else
{
    # Make PowerShell Disappear
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);' 
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru -ErrorAction Ignore
$null = $asyncwindow::ShowWindowAsync((get-process -name cmd | Where-Object MainWindowTitle -eq 'GUILauncher').MainWindowHandle, 0)

        $app = [Windows.Application]::New()
        $null = $app.Run($Window)
                # Force garbage collection just to start slightly lower RAM usage.
        [System.GC]::Collect()
}
    #endregion RUN APP

    IF ($output -ne "") {
        $output
    }
}

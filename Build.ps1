[cmdletBinding()]
Param(
    [Parameter()]
    [Switch]
    $Test,

    [Parameter()]
    [Switch]
    $Build,

    [Parameter()]
    [Switch]
    $Deploy
)

#Make some variables, shall we?
$innvocationPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$PSModuleRoot =  "H:\Documents\PS\GitHub\PSGUIHelper" #Split-Path -Parent $innvocationPath
$TestPath = Join-Path $PSModuleRoot "Tests"
$Build_ArtifactStagingDirectory = "H:\Documents\PS\Modules"
$modulename = "PSGUIHelper"

# Get the module manifest information
$moduleManifest = Get-ChildItem -Path $PSModuleRoot -Filter *.psd1

# Convert the manifest to a usable psobject
$manifestInfo = Import-PowerShellDataFile -Path $moduleManifest

#Do Stuff based on passed Args
Switch($true){

    $Test {

        If(-not (Get-Module Pester)){
            Install-Module -Name Pester -SkipPublisherCheck -Force
        }

        Invoke-Pester -Script $TestPath -OutputFile "$($Build_ArtifactStagingDirectory)\$modulename.Results.xml" -OutputFormat 'NUnitXml'

        #
        Get-ChildItem $env:Build_ArtifactStagingDirectory
    }

    $Build {


        $null = New-Item "$($Build_ArtifactStagingDirectory)\$modulename\$($manifestInfo.ModuleVersion)" -ItemType Directory

        Get-ChildItem $PSModuleRoot\Private\*.ps1 | Foreach-Object {

            Get-Content $_.FullName | Add-Content "$($Build_ArtifactStagingDirectory)\$modulename\$($manifestInfo.ModuleVersion)\$modulename.psm1"
        }
        Get-ChildItem $PSModuleRoot\Public\*.ps1 | Foreach-Object {

            Get-Content $_.FullName | Add-Content "$($Build_ArtifactStagingDirectory)\$modulename\$($manifestInfo.ModuleVersion)\$modulename.psm1"
        }


        Copy-Item "$PSModuleRoot\$modulename.psd1" "$($Build_ArtifactStagingDirectory)\$modulename\$($manifestInfo.ModuleVersion)" -Force

        Copy-Item -Path "$PSModuleRoot\assembly" "$($Build_ArtifactStagingDirectory)\$modulename\$($manifestInfo.ModuleVersion)" -Recurse -Force

        #Verification of contents
        Get-ChildItem -Path "$($Build_ArtifactStagingDirectory)\$modulename\$($manifestInfo.ModuleVersion)" -Recurse

        #Verify we can load the module and see cmdlets
        Import-Module "$($Build_ArtifactStagingDirectory)\$modulename\$($manifestInfo.ModuleVersion)\$modulename.psd1" -Force -Verbose

        Get-Command -Module $modulename | Select-Object CommandType, Name, Version, Source | Format-Table

    }

    $Deploy {

        
        Try {
            $deployCommands = @{
                Path = "C:\Users\Gaspack\Desktop\Powershell\Modules\PSGUIHelper"
                NuGetApiKey = "oy2ihobsm63d4qjhl3gqh5npewwm2aaexldqvegemnnzfe"
                ErrorAction = 'Stop'
            }
            
            Publish-Module @deployCommands
    
        }

        Catch {

            throw $_
    
        }
    
    }

    default {

        Write-Output "Please Provide one of the following switches: -Test, -Build, -Deploy"
    }

}
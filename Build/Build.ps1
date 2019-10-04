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
$PSModuleRoot = Split-Path -Parent $innvocationPath
$TestPath = Join-Path $PSModuleRoot "Tests"
$Build_ArtifactStagingDirectory = "c:\temp\"
$modulename = "GUIHelper"

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

        If(Test-Path "$($Build_ArtifactStagingDirectory)\$modulename"){
            Remove-Item "$($Build_ArtifactStagingDirectory)\$modulename" -Recurse -Force
        }

        $null = New-Item "$($Build_ArtifactStagingDirectory)\$modulename" -ItemType Directory

        Get-ChildItem $PSModuleRoot\Public\*.ps1 | Foreach-Object {

            Get-Content $_.FullName | Add-Content "$($Build_ArtifactStagingDirectory)\$modulename\$modulename.psm1"
        }

        Copy-Item "$PSModuleRoot\$modulename.psd1" "$($Build_ArtifactStagingDirectory)\$modulename"

        Copy-Item -Path "$PSModuleRoot\assembly" "$($Build_ArtifactStagingDirectory)\$modulename" -Recurse -Force

        #Verification of contents
        Get-ChildItem -Path "$($Build_ArtifactStagingDirectory)\$modulename" -Recurse

        #Verify we can load the module and see cmdlets
        Import-Module "$($Build_ArtifactStagingDirectory)\$modulename\$modulename.psd1"

        Get-Command -Module $modulename | Select-Object CommandType, Name, Version, Source | ft

    }

    $Deploy {

        
        Try {
    
            $deployCommands = @{
                Path = (Resolve-Path -Path "$($Build_ArtifactStagingDirectory)\PSChocoConfig")
                NuGetApiKey = $env:NuGetApiKey
                ErrorAction = 'Stop'
            }
            
            Publish-Module @deployCommands
    
        }

        Catch {

            throw $_
    
        }
    
    }

    default {

        echo "Please Provide one of the following switches: -Test, -Build, -Deploy"
    }

}
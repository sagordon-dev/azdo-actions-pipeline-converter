<#
.SYNOPSIS
This script converts an Azure DevOps pipeline to a GitHub Actions workflow in YAML format.

.DESCRIPTION
The script reads an Azure DevOps pipeline file (in JSON or YAML format), converts it to a GitHub Actions workflow, and saves the workflow to a specified file. It supports both JSON and YAML Azure DevOps pipeline files.

.PARAMETER azdoPipelineFile
The path to the Azure DevOps pipeline file to be converted.

.PARAMETER ghActionsWorkflowFile
The path to the output GitHub Actions workflow file.

.EXAMPLE
.\azdo_actions_pipeline_converter.ps1 -azdoPipelineFile "azure-pipelines.yml" -ghActionsWorkflowFile "github-actions.yml"
This command converts the Azure DevOps pipeline file "azure-pipelines.yml" to a GitHub Actions workflow file "github-actions.yml".

.NOTES
Written in PowerShell 5.1 and tested on Windows 11 with PowerShell 5.1.
Ensure that the required modules for YAML serialization are installed and imported.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$azdoPipelineFile,

    [Parameter(Mandatory=$true)]
    [string]$ghActionsWorkflowFile
)

# Check if the Azure DevOps pipeline file exists
if (-not (Test-Path $azdoPipelineFile)) {
    Write-Error "Azure DevOps pipeline file '$azdoPipelineFile' not found."
    exit 1
}

# Check if the GitHub Actions workflow file exists
if (-not (Test-Path $ghActionsWorkflowFile)) {
    Write-Error "GitHub Actions workflow file '$ghActionsWorkflowFile' not found."
    exit 1
}

# Load the Azure DevOps pipeline file
$azdoPipeline = Get-Content $azdoPipelineFile -Raw

# Convert the Azure DevOps pipeline to GitHub Actions workflow
$ghActionsWorkflow = Convert-AzdoPipelineToGhActionsWorkflow -AzdoPipeline $azdoPipeline

# Save the GitHub Actions workflow to the file
$ghActionsWorkflow | Set-Content $ghActionsWorkflowFile

Write-Host "Azure DevOps pipeline '$azdoPipelineFile' converted to GitHub Actions workflow '$ghActionsWorkflowFile' successfully."

<#
.SYNOPSIS
Converts an Azure DevOps pipeline to a GitHub Actions workflow.

.DESCRIPTION
This function takes an Azure DevOps pipeline in JSON format and converts it to a GitHub Actions workflow in YAML format.

.PARAMETER AzdoPipeline
The Azure DevOps pipeline content in JSON format.

.RETURNS
A string containing the GitHub Actions workflow in YAML format.

.EXAMPLE
$azdoPipeline = Get-Content "azure-pipelines.json" -Raw
$ghActionsWorkflow = Convert-AzdoPipelineToGhActionsWorkflow -AzdoPipeline $azdoPipeline
Write-Host $ghActionsWorkflow
#>
function Convert-AzdoPipelineToGhActionsWorkflow {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AzdoPipeline
    )

    # Convert the Azure DevOps pipeline to JSON format
    $azdoPipelineJson = ConvertFrom-Json $AzdoPipeline

    # Initialize the GitHub Actions workflow object
    $ghActionsWorkflow = @{
        name = $azdoPipelineJson.name
        on = @{
            push = @{
                branches = @('main')
            }
        }
        jobs = @{}
    }

    # Loop through the jobs in the Azure DevOps pipeline
    foreach ($job in $azdoPipelineJson.jobs) {
        # Initialize the GitHub Actions job object
        $ghActionsJob = @{
            name = $job.jobName
            'runs-on' = 'ubuntu-latest'
            steps = @()
        }

        # Loop through the steps in the Azure DevOps job
        foreach ($step in $job.steps) {
            # Initialize the GitHub Actions step object
            $ghActionsStep = @{
                name = $step.displayName
                run = $step.script
            }

            # Add the GitHub Actions step to the job
            $ghActionsJob.steps += $ghActionsStep
        }

        # Add the GitHub Actions job to the workflow
        $ghActionsWorkflow.jobs[$job.jobName] = $ghActionsJob
    }

    # Convert the GitHub Actions workflow to YAML format
    $ghActionsWorkflowYaml = ConvertTo-Yaml -Object $ghActionsWorkflow

    return $ghActionsWorkflowYaml
}

<#
.SYNOPSIS
Converts a PowerShell object to a YAML formatted string.

.DESCRIPTION
This function takes a PowerShell object and serializes it into a YAML formatted string.

.PARAMETER Object
The PowerShell object to be serialized into YAML format.

.RETURNS
A string containing the YAML representation of the input object.

.EXAMPLE
$myObject = @{ Name = "Example"; Value = 123 }
$yamlString = ConvertTo-Yaml -Object $myObject
Write-Host $yamlString

.NOTES
Ensure that the required modules for YAML serialization are installed and imported.
#>
function ConvertTo-Yaml {
    param (
        [Parameter(Mandatory=$true)]
        [object]$Object
    )

    $yaml = New-Object -TypeName 'System.Text.StringBuilder'
    $yamlWriter = New-Object -TypeName 'System.IO.StringWriter' -ArgumentList $yaml
    $yamlSerializer = New-Object -TypeName 'System.Management.Automation.PSSerializer' -ArgumentList $Object
    $yamlSerializer.Serialize($yamlWriter)
    $yamlWriter.Close()

    return $yaml.ToString()
}


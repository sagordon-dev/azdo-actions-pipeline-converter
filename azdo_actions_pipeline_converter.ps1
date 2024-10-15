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

function Get-PipelineFile {
    param (
        [string]$PipelineFile
    )

    if (-Not (Test-Path -Path $PipelineFile)) {
        throw "The file $PipelineFile does not exist."
    }

    $extension = [System.IO.Path]::GetExtension($PipelineFile).ToLower()
    $content = Get-Content -Path $PipelineFile -Raw

    switch ($extension) {
        ".json" { return $content | ConvertFrom-Json }
        ".yaml" { return $content | ConvertFrom-Yaml }
        ".yml"  { return $content | ConvertFrom-Yaml }
        default { throw "Unsupported file format. Please provide a .json or .yaml file." }
    }
}

function Convert-AzdoPipelineToGhActionsWorkflow {
    param (
        [hashtable]$Pipeline
    )

    $workflow = @{
        name = $Pipeline.name
        on   = @('push', 'pull_request')
        jobs = @{}
    }

    if ($Pipeline.ContainsKey('phases')) {
        $phases = $Pipeline.phases
        foreach ($phase in $phases) {
            $jobName = $phase.name
            $workflow.jobs[$jobName] = @{
                'runs-on' = 'ubuntu-latest'
                steps     = @()
            }
            foreach ($step in $phase.steps) {
                $workflow.jobs[$jobName].steps += @{
                    name = $step.displayName
                    run  = $step.script
                }
            }
        }
    } elseif ($Pipeline.ContainsKey('jobs')) {
        $jobs = $Pipeline.jobs
        foreach ($job in $jobs) {
            $jobName = $job.job
            $workflow.jobs[$jobName] = @{
                'runs-on' = 'ubuntu-latest'
                steps     = @()
            }
            foreach ($step in $job.steps) {
                $workflow.jobs[$jobName].steps += @{
                    name = $step.displayName
                    run  = $step.script
                }
            }
        }
    } elseif ($Pipeline.ContainsKey('stages')) {
        $stages = $Pipeline.stages
        foreach ($stage in $stages) {
            foreach ($job in $stage.jobs) {
                $jobName = $job.job
                $workflow.jobs[$jobName] = @{
                    'runs-on' = 'ubuntu-latest'
                    steps     = @()
                }
                foreach ($step in $job.steps) {
                    $workflow.jobs[$jobName].steps += @{
                        name = $step.displayName
                        run  = $step.script
                    }
                }
            }
        }
    } else {
        throw "Error: 'phases', 'jobs', or 'stages' key not found in pipeline. Pipeline content: $Pipeline"
    }

    return $workflow
}

function Write-GitHubActionsWorkflow {
    param (
        [hashtable]$Workflow,
        [string]$OutputFile
    )

    try {
        $yamlContent = ConvertTo-Yaml -Object $Workflow
        Set-Content -Path $OutputFile -Value $yamlContent
    } catch {
        throw "Error: $_"
    }
}

function ConvertTo-Yaml {
    param (
        [Parameter(Mandatory=$true)]
        [object]$Object
    )

    $yaml = New-Object -TypeName 'System.Text.StringBuilder'
    $yamlWriter = New-Object -TypeName 'System.IO.StringWriter' -ArgumentList $yaml
    $yamlSerializer = New-Object -TypeName 'YamlDotNet.Serialization.Serializer'
    $yamlSerializer.Serialize($yamlWriter, $Object)
    $yamlWriter.Close()

    return $yaml.ToString()
}

try {
    $pipeline = Get-PipelineFile -PipelineFile $azdoPipelineFile
    $workflow = Convert-AzdoPipelineToGhActionsWorkflow -Pipeline $pipeline
    Write-GitHubActionsWorkflow -Workflow $workflow -OutputFile $ghActionsWorkflowFile
    Write-Host "GitHub Actions workflow file $ghActionsWorkflowFile is created successfully."
} catch {
    Write-Error $_
}
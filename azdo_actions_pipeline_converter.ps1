<#
.SYNOPSIS
This script converts an Azure DevOps pipeline to a GitHub Actions workflow in YAML format.

.DESCRIPTION
The script reads an Azure DevOps pipeline file (in JSON or YAML format), converts it to a GitHub Actions workflow, and saves the workflow to a specified file. It supports both JSON and YAML Azure DevOps pipeline files.

.PARAMETER azdoPipelineFile
The path to the Azure DevOps pipeline file to be converted.

.PARAMETER ghActionsWorkflowFileName
The path to the output GitHub Actions workflow file.

.EXAMPLE
.\azdo_actions_pipeline_converter.ps1 -azdoPipelineFile "azure-pipelines.yml" -ghActionsWorkflowFile "github-actions.yml"
This command converts the Azure DevOps pipeline file "azure-pipelines.yml" to a GitHub Actions workflow file "github-actions.yml".

.NOTES
Written in PowerShell 5.1 and tested on Windows 11 with PowerShell 5.1.
Ensure that the required modules for YAML serialization are installed and imported.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$azdoPipelineFile,

    [Parameter(Mandatory = $true)]
    [string]$ghActionsWorkflowFileName
)

function Install-RequiredModules {
    $modules = @('powershell-yaml')

    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing module: $module"
            try {
                Install-Module -Name $module -Force -Scope CurrentUser -ErrorAction Stop
            }
            catch {
                throw "Failed to install module: $module. Error: $_"
            }
        }
    }
}

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
        ".yml" { return $content | ConvertFrom-Yaml }
        default { throw "Unsupported file format. Please provide a .json or .yaml file." }
    }
}

function Convert-AzdoPipelineToGhActionsWorkflow {
    param (
        [hashtable]$Pipeline
    )

    $workflow = @{
        name = $Pipeline.name
        on   = @{
            push         = @{
                branches = @('main')
            }
            pull_request = @{
                branches = @('main')
            }
        }
        jobs = @{}
    }

    if ($Pipeline.ContainsKey('trigger')) {
        $workflow.on.push.branches = $Pipeline.trigger.branches
    }

    if ($Pipeline.ContainsKey('pr')) {
        $workflow.on.pull_request.branches = $Pipeline.pr.branches
    }

    if ($Pipeline.ContainsKey('variables')) {
        $workflow.env = @{}
        foreach ($key in $Pipeline.variables.Keys) {
            $workflow.env[$key] = $Pipeline.variables[$key]
        }
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
    }
    elseif ($Pipeline.ContainsKey('jobs')) {
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
    }
    elseif ($Pipeline.ContainsKey('stages')) {
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
    }
    else {
        throw "Error: 'phases', 'jobs', or 'stages' key not found in pipeline. Pipeline content: $Pipeline"
    }

    # Ensure jobs are not empty
    if ($workflow.jobs.Count -eq 0) {
        throw "No jobs found in the pipeline. Ensure the pipeline contains 'phases', 'jobs', or 'stages'."
    }

    return $workflow
}



function Write-GitHubActionsWorkflow {
    param (
        [hashtable]$Workflow,
        [string]$OutputFile
    )

    try {
        if ([string]::IsNullOrWhiteSpace($OutputFile)) {
            throw "Output file path is empty or null."
        }

        $outputDir = [System.IO.Path]::GetDirectoryName($OutputFile)
        Write-Host "Output directory: $outputDir"

        if (-Not (Test-Path -Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force
        }

        try {
            # Adjusted the ConvertTo-Yaml call
            $yamlContent = $Workflow | ConvertTo-Yaml -ErrorAction Stop
        }
        catch {
            throw "Failed to convert to YAML. Ensure the 'powershell-yaml' module is installed. Error: $_"
        }

        Set-Content -Path $OutputFile -Value $yamlContent
    }
    catch {
        throw "Error: $_"
    }
}


try {
    Install-RequiredModules
    Import-Module -Name powershell-yaml -ErrorAction Stop

    $pipeline = Get-PipelineFile -PipelineFile $azdoPipelineFile

    $outputDir = ".github/workflows"
    if (-Not (Test-Path -Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force
    }

    $ghActionsWorkflowFile = Join-Path -Path $outputDir -ChildPath $ghActionsWorkflowFileName

    $workflow = Convert-AzdoPipelineToGhActionsWorkflow -Pipeline $pipeline
    Write-GitHubActionsWorkflow -Workflow $workflow -OutputFile $ghActionsWorkflowFile

    Write-Host "GitHub Actions workflow file $ghActionsWorkflowFile is created successfully."
}
catch {
    Write-Error $_
}

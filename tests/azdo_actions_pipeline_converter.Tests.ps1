# azdo_actions_pipeline_converter.Tests.ps1

# Import the module to be tested
. "$PSScriptRoot/azdo_actions_pipeline_converter.ps1"

Describe "Azure DevOps to GitHub Actions Pipeline Converter" {

    BeforeAll {
        # Mock the Install-Module cmdlet to prevent actual module installation during tests
        Mock -CommandName Install-Module -MockWith { return }
        Mock -CommandName Import-Module -MockWith { return }
        Mock -CommandName ConvertTo-Yaml -MockWith { param($Object) return "yaml-content" }
        Mock -CommandName Set-Content -MockWith { param($Path, $Value) return }
    }

    Context "Module Installation" {
        It "Should install required modules if not already installed" {
            # Arrange
            Mock -CommandName Get-Module -MockWith { return $null }

            # Act
            Install-RequiredModules

            # Assert
            Assert-MockCalled -CommandName Install-Module -Exactly -Times 1
        }
    }

    Context "Pipeline File Reading" {
        It "Should throw an error if the pipeline file does not exist" {
            # Arrange
            $nonExistentFile = "nonexistent.yml"

            # Act & Assert
            { Get-PipelineFile -PipelineFile $nonExistentFile } | Should -Throw "The file $nonExistentFile does not exist."
        }

        It "Should read and convert a JSON pipeline file" {
            # Arrange
            $jsonFile = "pipeline.json"
            $jsonContent = '{"name": "test-pipeline"}'
            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-Content -MockWith { return $jsonContent }

            # Act
            $result = Get-PipelineFile -PipelineFile $jsonFile

            # Assert
            $result.name | Should -Be "test-pipeline"
        }

        It "Should read and convert a YAML pipeline file" {
            # Arrange
            $yamlFile = "pipeline.yml"
            $yamlContent = "name: test-pipeline"
            Mock -CommandName Test-Path -MockWith { return $true }
            Mock -CommandName Get-Content -MockWith { return $yamlContent }

            # Act
            $result = Get-PipelineFile -PipelineFile $yamlFile

            # Assert
            $result.name | Should -Be "test-pipeline"
        }
    }

    Context "Pipeline Conversion" {
        It "Should convert an Azure DevOps pipeline to a GitHub Actions workflow" {
            # Arrange
            $pipeline = @{
                name = "test-pipeline"
                stages = @(
                    @{
                        stage = "Build"
                        jobs = @(
                            @{
                                job = "BuildJob"
                                steps = @(
                                    @{
                                        displayName = "Build step"
                                        script = "echo Build"
                                    }
                                )
                            }
                        )
                    }
                )
            }

            # Act
            $workflow = Convert-AzdoPipelineToGhActionsWorkflow -Pipeline $pipeline

            # Assert
            $workflow.name | Should -Be "test-pipeline"
            $workflow.jobs.BuildJob.steps.name | Should -Be "Build step"
        }
    }

    Context "Workflow Writing" {
        It "Should write the GitHub Actions workflow to a file" {
            # Arrange
            $workflow = @{
                name = "test-workflow"
                jobs = @{
                    BuildJob = @{
                        'runs-on' = 'ubuntu-latest'
                        steps = @(
                            @{
                                name = "Build step"
                                run = "echo Build"
                            }
                        )
                    }
                }
            }
            $outputFile = "github-actions.yml"

            # Act
            Write-GitHubActionsWorkflow -Workflow $workflow -OutputFile $outputFile

            # Assert
            Assert-MockCalled -CommandName Set-Content -Exactly -Times 1 -Scope It
        }
    }
}


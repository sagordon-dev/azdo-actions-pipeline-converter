# Azure DevOps to GitHub Actions Pipeline Converter

This script converts an Azure DevOps pipeline to a GitHub Actions workflow in YAML format. It reads an Azure DevOps pipeline file (in JSON or YAML format), converts it to a GitHub Actions workflow, and saves the workflow to a specified file. The script supports both JSON and YAML Azure DevOps pipeline files.

## Prerequisites
- **PowerShell 5.1 or later**: Ensure you have PowerShell installed on your machine.
- **Required Modules**: The script requires the `powershell-yaml` module for YAML serialization. The script will automatically install this module if it is not already installed.

## Installation
1. **Clone the Repository**:
   ```sh
   git clone <repository-url>
   cd <repository-directory>

2. **Ensure PowerShell is Installed**:
    * For Windows: PowerShell is pre-installed.
    * For macOS/Linux: Follow the instructions here to install PowerShell.

## Usage
1. **Open PowerShell**:

    * On Windows, you can open PowerShell by searching for it in the Start menu.
    * On macOS/Linux, open your terminal and type pwsh to start PowerShell.

2. **Navigate to the Script Directory**:
```bash
cd path/to/your/script
```

3. **Run the Script**:
```bash
.\azdo_actions_pipeline_converter.ps1 -azdoPipelineFile "path/to/azure-pipelines.yml" -ghActionsWorkflowFileName "path/to/github-actions.yml"
```
    * azdoPipelineFile: The path to the Azure DevOps pipeline file to be converted.
    * ghActionsWorkflowFileName: The path to the output GitHub Actions workflow file.

### Example
To convert an Azure DevOps pipeline file named azure-pipelines.yml to a GitHub Actions workflow file named github-actions.yml, run the following command:
```bash
.\azdo_actions_pipeline_converter.ps1 -azdoPipelineFile "azure-pipelines.yml" -ghActionsWorkflowFileName "github-actions.yml"
```

## Script Details

### Parameters
* `azdoPipelineFile`: The path to the Azure DevOps pipeline file to be converted. This parameter is mandatory.
* `ghActionsWorkflowFileName`: The path to the output GitHub Actions workflow file. This parameter is mandatory.

### Functions
* `Install-RequiredModules`: Installs the required PowerShell modules if they are not already installed.
* `Get-PipelineFile`: Reads the Azure DevOps pipeline file and converts it to a PowerShell object.
* `Convert-AzdoPipelineToGhActionsWorkflow`: Converts the Azure DevOps pipeline object to a GitHub Actions workflow object.
* `Write-GitHubActionsWorkflow`: Writes the GitHub Actions workflow object to a YAML file.

### Troubleshooting
* **Module Installation Issues**: If the script fails to install the required modules, ensure you have the necessary permissions to install PowerShell modules. You may need to run PowerShell as an administrator.
* **File Path Issues**: Ensure the paths provided for the azdoPipelineFile and ghActionsWorkflowFileName parameters are correct and accessible.
* **YAML Conversion Errors**: If there are issues with converting to YAML, ensure the powershell-yaml module is installed correctly.

### Contributing
If you encounter any issues of have suggestions for improvements, feel free to open an issue or submit a pull request.

### License
This project is licensed under the MIT License. See the LICENSE file for details.

For any further questions or support, please contact Scott at scott.gordon72@outlook.com.
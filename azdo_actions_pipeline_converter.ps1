try {
    if ([string]::IsNullOrWhiteSpace($OutputFile)) {
        throw "Output file path is empty or null."
    }

    $outputDir = [System.IO.Path]::GetDirectoryName((Resolve-Path $OutputFile).Path)
    if ([string]::IsNullOrWhiteSpace($outputDir)) {
        throw "Output directory path is empty or null."
    }

    if (-Not (Test-Path -Path $outputDir)) {
        $createDir = Read-Host "Output directory '$outputDir' does not exist. Do you want to create it? (Y/N)"
        if ($createDir -eq 'Y' -or $createDir -eq 'y') {
            New-Item -ItemType Directory -Path $outputDir -Force
        } else {
            throw "Output directory '$outputDir' does not exist and was not created."
        }
    }

    $yamlContent = ConvertTo-Yaml -Object $Workflow
    Set-Content -Path $OutputFile -Value $yamlContent
} catch {
    throw "Error: $_"
}
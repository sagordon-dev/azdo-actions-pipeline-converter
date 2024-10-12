# Azure DevOps to GitHub Actions Pipeline Converter

This script converts an Azure DevOps pipeline to a GitHub Actions workflow in YAML format.

## Requirements

- Python 3.12.3
- `pyyaml` library

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-repo/azdo-actions-pipeline-converter.git
    cd azdo-actions-pipeline-converter
    ```

2. Create a virtual environment:
    ```bash
    python3 -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```

3. Install the required libraries:
    ```bash
    pip install -r requirements.txt
    ```

## Usage

1. Place your Azure DevOps pipeline JSON file in the `src` directory.

2. Run the script:
    ```bash
    python src/azdo_actions_pipeline_converter.py --pipeline-file <path_to_pipeline_file> --output-file <path_to_output_file>
    ```

    - `--pipeline-file`: Path to the Azure DevOps pipeline JSON file.
    - `--output-file`: Path to save the generated GitHub Actions workflow YAML file.

## Example

```bash
python src/azdo_actions_pipeline_converter.py --pipeline-file src/azure-pipeline.json --output-file .github/workflows/ci.yml
```

## Running Tests

1. Ensure you are in the virtual environment:

```bash
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
```

2. Run the tests:

```bash
python3 -m unittest discover -s tests
```

## File Structure
```
project/
│
├── src/
│   └── azdo-actions-pipeline-converter.py
│
├── tests/
│   └── test_azdo_actions_pipeline_converter.py
│
├── .gitignore
├── requirements.txt
└── README.md
```

## License

This project is licensed under the MIT License.

### Additional Steps

1. **Create `requirements.txt`**:
   - Add the required libraries.

```plaintext
pyyaml
```

2. **Update `.gitignore:`**:
* Ensure it includes the virtual environment directory.

#### Virtual environment
```bash
venv/
```

#### Directory Structure

```bash
project/
│
├── src/
│   └── azdo-actions-pipeline-converter.py
│
├── tests/
│   └── test_azdo_actions_pipeline_converter.py
│
├── .gitignore
├── requirements.txt
└── README.md
```
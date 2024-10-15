"""
This script converts Azure DevOps pipeline to GitHub Actions workflow in YAML format.
It is written in Python 3.12.3 and tested on Windows 11 with Python 3.12.3.
It supports both JSON and YAML Azure DevOps pipeline files.
"""

import os
import sys
import json
import yaml
import argparse
import re

def get_pipeline_file(pipeline_file):
    """
    Reads the Azure DevOps pipeline file and returns its content.
    Supports both JSON and YAML formats.
    """
    if not os.path.isfile(pipeline_file):
        raise FileNotFoundError(f"The file {pipeline_file} does not exist.")
    
    with open(pipeline_file, 'r') as file:
        if pipeline_file.endswith('.json'):
            return json.load(file)
        elif pipeline_file.endswith('.yaml') or pipeline_file.endswith('.yml'):
            return yaml.safe_load(file)
        else:
            raise ValueError("Unsupported file format. Please provide a .json or .yaml file.")

def get_github_actions_workflow(pipeline):
    try:
        if 'phases' not in pipeline:
            print(f"Error: 'phases' key not found in pipeline. Pipeline content: {pipeline}")
            sys.exit(1)
        
        workflow = {}
        workflow['name'] = pipeline['name']
        workflow['on'] = ['push', 'pull_request']
        workflow['jobs'] = {}
        job = {}
        job['runs-on'] = 'ubuntu-latest'
        job['steps'] = []
        phases = pipeline['phases']
        
        for step in pipeline['phases'][0]['steps']:
            step_dict = {}
            step_dict['name'] = step['displayName']
            step_dict['run'] = step['script']
            job['steps'].append(step_dict)
        workflow['jobs']['build'] = job
        return workflow
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def write_github_actions_workflow(workflow, output_file):
    try:
        with open(output_file, 'w') as file:
            yaml.dump(workflow, file)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Convert Azure DevOps pipeline to GitHub Actions workflow in YAML format.')
    parser.add_argument('-i', '--input', help='Azure DevOps pipeline file in JSON format', required=True)
    parser.add_argument('-o', '--output', help='GitHub Actions workflow file in YAML format', required=True)
    args = parser.parse_args()
    pipeline_file = args.input
    output_file = args.output
    pipeline = get_pipeline_file(pipeline_file)
    workflow = get_github_actions_workflow(pipeline)
    write_github_actions_workflow(workflow, output_file)
    print(f"GitHub Actions workflow file {output_file} is created successfully.")

if __name__ == '__main__':
    main()

# End of script

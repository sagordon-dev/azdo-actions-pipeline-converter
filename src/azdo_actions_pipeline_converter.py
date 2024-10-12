"""
This script converts Azure DevOps pipeline to GitHub Actions workflow in YAML format.
It is written in Python 3.12.3 and tested on Windows 11 with Python 3.12.3.
"""

import os
import sys
import json
import yaml
import argparse
import re

def get_pipeline_file(pipeline_file):
    """
    Reads a JSON pipeline file and returns its content as a dictionary.

    Args:
        pipeline_file (str): Path to the Azure DevOps pipeline JSON file.

    Returns:
        dict: Parsed content of the pipeline file.

    Raises:
        Exception: If there is an error reading or parsing the file.
    """
    try:
        with open(pipeline_file, 'r') as file:
            pipeline = json.load(file)
            return pipeline
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def get_github_actions_workflow(pipeline):
    try:
        workflow = {}
        workflow['name'] = pipeline['name']
        workflow['on'] = ['push', 'pull_request']
        workflow['jobs'] = {}
        job = {}
        job['runs-on'] = 'ubuntu-latest'
        job['steps'] = []
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

import os
import sys
import json
import yaml
import argparse
import logging

def setup_logging():
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def get_pipeline_file(pipeline_file):
    """
    Reads the Azure DevOps pipeline file and returns its content.
    Supports both JSON and YAML formats.
    """
    if not os.path.isfile(pipeline_file):
        logging.error(f"The file {pipeline_file} does not exist.")
        sys.exit(1)
    
    with open(pipeline_file, 'r') as file:
        if pipeline_file.endswith('.json'):
            return json.load(file)
        elif pipeline_file.endswith('.yaml') or pipeline_file.endswith('.yml'):
            return yaml.safe_load(file)
        else:
            logging.error("Unsupported file format. Please provide a .json or .yaml file.")
            sys.exit(1)

def convert_pipeline_to_workflow(pipeline):
    """
    Converts the Azure DevOps pipeline to a GitHub Actions workflow.
    """
    workflow = {
        'name': pipeline.get('name', 'CI Pipeline'),
        'on': {
            'push': {'branches': ['main']},
            'pull_request': {'branches': ['main']}
        },
        'jobs': {}
    }

    if 'trigger' in pipeline:
        workflow['on']['push']['branches'] = pipeline['trigger'].get('branches', ['main'])

    if 'pr' in pipeline:
        workflow['on']['pull_request']['branches'] = pipeline['pr'].get('branches', ['main'])

    if 'variables' in pipeline:
        workflow['env'] = {k: v for k, v in pipeline['variables'].items()}

    if 'variableGroups' in pipeline:
        for group in pipeline['variableGroups']:
            for variable in group['variables']:
                workflow['env'][variable['name']] = variable['value']

    if 'resources' in pipeline:
        workflow['resources'] = {}
        if 'repositories' in pipeline['resources']:
            workflow['resources']['repositories'] = [
                {'repository': repo['repository'], 'type': repo['type'], 'ref': repo['ref']}
                for repo in pipeline['resources']['repositories']
            ]

    if 'phases' in pipeline:
        for phase in pipeline['phases']:
            job_name = phase['name']
            workflow['jobs'][job_name] = {
                'runs-on': 'ubuntu-latest',
                'steps': [{'name': step['displayName'], 'run': step['script']} for step in phase['steps']]
            }
    elif 'jobs' in pipeline:
        for job in pipeline['jobs']:
            job_name = job['job']
            workflow['jobs'][job_name] = {
                'runs-on': 'ubuntu-latest',
                'steps': [{'name': step['displayName'], 'run': step['script']} for step in job['steps']]
            }
    elif 'stages' in pipeline:
        for stage in pipeline['stages']:
            for job in stage['jobs']:
                job_name = job['job']
                workflow['jobs'][job_name] = {
                    'runs-on': 'ubuntu-latest',
                    'steps': [{'name': step['displayName'], 'run': step['script']} for step in job['steps']]
                }
    else:
        logging.error("Error: 'phases', 'jobs', or 'stages' key not found in pipeline.")
        sys.exit(1)

    return workflow

def write_workflow_to_file(workflow, output_file):
    """
    Writes the GitHub Actions workflow to a file.
    """
    try:
        with open(output_file, 'w') as file:
            yaml.dump(workflow, file)
        logging.info(f"GitHub Actions workflow file {output_file} is created successfully.")
    except Exception as e:
        logging.error(f"Error writing workflow to file: {e}")
        sys.exit(1)

def main():
    setup_logging()
    
    parser = argparse.ArgumentParser(description='Convert Azure DevOps pipeline to GitHub Actions workflow in YAML format.')
    parser.add_argument('-i', '--input', help='Azure DevOps pipeline file in JSON or YAML format', required=True)
    parser.add_argument('-o', '--output', help='GitHub Actions workflow file in YAML format', required=True)
    args = parser.parse_args()

    pipeline_file = args.input
    output_file = args.output

    pipeline = get_pipeline_file(pipeline_file)
    workflow = convert_pipeline_to_workflow(pipeline)
    write_workflow_to_file(workflow, output_file)

if __name__ == '__main__':
    main()
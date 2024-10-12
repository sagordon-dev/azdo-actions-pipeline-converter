import unittest
import yaml
import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../src')))
from azdo_actions_pipeline_converter import write_github_actions_workflow

class TestAzdoActionsPipelineConverter(unittest.TestCase):

    def test_write_github_actions_workflow(self):
        workflow = {
            'name': 'CI',
            'on': ['push'],
            'jobs': {
                'build': {
                    'runs-on': 'ubuntu-latest',
                    'steps': [
                        {'name': 'Checkout code', 'uses': 'actions/checkout@v2'},
                        {'name': 'Set up Python', 'uses': 'actions/setup-python@v2', 'with': {'python-version': '3.8'}},
                        {'name': 'Install dependencies', 'run': 'pip install -r requirements.txt'},
                        {'name': 'Run tests', 'run': 'pytest'}
                    ]
                }
            }
        }
        output_file = 'test_workflow.yml'
        write_github_actions_workflow(workflow, output_file)
        
        with open(output_file, 'r') as file:
            content = yaml.safe_load(file)
        
        self.assertEqual(content, workflow)
        
        os.remove(output_file)

if __name__ == '__main__':
    unittest.main()
import os
from odoo import http
import requests
import subprocess
import json
import logging
logger = logging.getLogger(__name__)

class create_gitlab_runner(http.Controller):
    @http.route('/gitlab-runner-result-page', auth='public', website=True, csrf=False)
    def handle_post_request(self, **post):
        logger.info('Starting create_gitlab_runner class and handle_post_request function')
        # Setting present working directory
        working_directory = os.path.dirname(os.path.realpath(__file__))

        # Receiving the github repository URL and token via pull request
        runner_creation_token = post.get('runner_token')
        
        # Check if the response was successful (status code 200)

        if runner_creation_token!=None:
            command = ['/bin/bash', f"{working_directory}/new_runner.sh", runner_creation_token, working_directory ]
            completed_process = subprocess.run(command, capture_output=True, text=True, check=True)
            logger.info(f"STDOUT: {completed_process.stdout}")
            logger.error(f"STDERR: {completed_process.stderr}")
            return http.request.render('cloudv_gitlab_riscv_runner.runner_creation_complete',
                {
                    'runner_token':runner_creation_token, 
                }
            )
        else:
            access_token="No access token Recieved from GitHub!"
            return http.request.render('cloudv_gitlab_riscv_runner.no_registration_token')

import os
from odoo import http
import requests

class main(http.Controller):
    @http.route('/gitlab-riscv-runner', auth='public', website=True)
    def render_github_repo_page(self, **post):
        return http.request.render('cloudv_gitlab_riscv_runner.runner_token_ask')

from libs.github_client import GithubClient
from libs.template import Template
from libs.csv_writter import CSVWritter

import os

github_client = GithubClient(os.environ['GH_TOKEN'])

for topic in ['docker', 'ansible', 'terraform', 'packer']:
  section = 'resources/data/' + topic + '.adoc'
  github_reponse = github_client.get_repositories_from_users_by_topic(
    users=['fabioluciano', 'integr8', 'utils-docker'],
    topic=topic
  )
  Template(template_file = 'repositories-list.adoc.jinja2', data = github_reponse).write(section)
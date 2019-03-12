from github_client import GithubClient
from template import Template
from csv_writter import CSVWritter

import os

github_client = GithubClient(os.environ['GH_TOKEN'])

for topic in ['docker', 'ansible', 'terraform', 'packer']:
  csv_path = 'resources/data/' + topic + '.csv'

  CSVWritter(github_client.get_repositories_from_users_by_topic(
    users=['fabioluciano', 'integr8', 'utils-docker'],
    topic=topic
  )).write(csv_path)
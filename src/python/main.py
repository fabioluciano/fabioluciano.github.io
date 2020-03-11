from os.path import dirname, abspath
from os import environ

from libs.github_client import GithubClient
from libs.template import Template
from libs.csv_writter import CSVWritter

github_client = GithubClient(environ['GH_TOKEN'])
section_dir = dirname(dirname(abspath(__file__))) + '/resources/data/'

for topic in ['docker', 'ansible', 'terraform', 'packer']:
  section = section_dir + topic + '.adoc'
  github_reponse = github_client.get_repositories_from_users_by_topic(
    users=['fabioluciano', 'integr8', 'utils-docker'],
    topic=topic
  )
  Template(template_file = 'repositories-list.adoc.jinja2', data = github_reponse).write(section)
  
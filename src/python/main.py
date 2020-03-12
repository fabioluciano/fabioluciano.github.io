from os.path import dirname, abspath
from os import environ
from collections import Counter

from libs.github_client import GithubClient
from libs.template import Template
from libs.csv_writter import CSVWritter

github_client = GithubClient(environ['GH_TOKEN'])
section_dir = dirname(dirname(abspath(__file__))) + '/resources/data/'

repositories = github_client.get_repositories_by_users(
  users=['fabioluciano', 'integr8', 'utils-docker'],
)

all_topics = [val for sublist in repositories if len(sublist['topics']) for val in sublist['topics']]
most_common_topic = Counter(all_topics).most_common(8)
most_common_topic_list = [ topic[0] for topic in most_common_topic]
oxford_comma = ", ".join(most_common_topic_list[:-2] + [" e ".join(most_common_topic_list[-2:])])

for topic in ['docker', 'ansible', 'terraform', 'packer']:
  section = section_dir + topic + '.adoc'
  filtered_repos = [repository for repository in repositories if topic in repository['topics']]
  Template(template_file = 'repositories-list.adoc.jinja2', data = filtered_repos).write(section)
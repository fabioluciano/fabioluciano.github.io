from github import Github

class GithubClient:

  def __init__(self, token):
    self.github_instance = Github(token)
    self.result = []

  def get_repositories_from_users_by_topic(self, users=[], topics = []):
    for user in users:
      github_user = self.github_instance.get_user(user)

      for repository in github_user.get_repos():
        temp_repository = {}
        temp_repository.update({ 'name': repository.name })
        temp_repository.update({ 'html_url': repository.html_url })
        temp_repository.update({ 'description': repository.description })
        temp_repository.update({ 'homepage': repository.homepage })
        self.result.append(temp_repository)

    print(self.result)


github_client = GithubClient('')

github_client.get_repositories_from_users_by_topic(users=['fabioluciano', 'integr8', 'utils-docker'])
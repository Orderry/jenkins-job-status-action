# Start jenkins multibranch branch/PR job 

This action starts Jenkins Multibranch pipeline branch/PR job with previous status checks. Not wotking with tags!

## Inputs

### `jenkins_user`
**Required** Jenkins user login.
### `jenkins_token`
**Required** Jenkins user token. https://support.cloudbees.com/hc/en-us/articles/115003090592-How-to-re-generate-my-Jenkins-user-token.
### `jenkins_url`
**Required** Jenkins url. Example: `"https://jenkins.yourdomain.com"`.
### `job_name`
**Required** Job name. Example: `"job/manual-deploy-environment-sandbox/job"`.
### `branch_name`
**Required** Clear branch/PR name. Example: `"DEV-1234"`, `"PR-77"`.

## Outputs

### `status`
Job status color from API
### `decision`
Startup type message
### `result`
Result of POST call to Jenkins Job API
## Example usage

uses: Orderry/jenkins-job-status@v1.1
with:
  jenkins_user: 'username'
  jenkins_token: 'token'
  jenkins_url: 'https://jenkins.yourdomain.com
  job_name: 'job/name-of-triggering-job/job'
  branch_name: 'DEV-1234'
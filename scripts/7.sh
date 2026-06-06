# Make sure you are able to push to your repo
mkdir .github
cd .github
mkdir workflows

# Going over https://github.com/EliMutchnik/devops-experts/tree/main/github-workflows

## Class exercise
Create a GitHub Actions workflow with three jobs:
	1.	Job 1 - Compare the contents of a file with a GitHub Actions repository variable. Fail if they differ.
	2.	Job 2 - Compare the contents of a different file directly with a GitHub Actions secret. Fail if they differ.
	3.	Job 3 - Run only if Jobs 1 and 2 succeed. Print the file value and variable value. Do not print the secret.

Requirements
	•	Use a multi-job workflow
	•	Use repository variables and secrets
	•	Use job dependencies (needs)
	•	Trigger the workflow with workflow_dispatch

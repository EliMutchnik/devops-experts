# Make sure you are able to push to your repo

# Warming up
https://github.com/avielb/advanced-devops/blob/master/.github/workflows/01-example.yaml

# Sequence and Parallel
https://github.com/avielb/advanced-devops/blob/master/.github/workflows/seq-and-para.yaml

# Matrix
https://github.com/avielb/advanced-devops/blob/master/.github/workflows/matrix.yaml

# Build and push
## 1. Create Dockerhub tokens: https://app.docker.com/accounts/elimutch/settings/personal-access-tokens
##    Add DOCKERHUB_USERNAME and DOCKERHUB_TOKEN github secrets

## 2. In root dir create Dockerfile:

FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
CMD ["python", "app.py"]

## 3. In root dir create app.py:

from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from GitHub Actions + Docker!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

## 4. In root dir create requirements.txt:

pytest
flask

# Create build and push workflow
https://github.com/avielb/advanced-devops/blob/master/.github/workflows/docker-build-push.yaml

# Create PR and add comment
https://github.com/avielb/advanced-devops/blob/master/.github/workflows/pr-comment.yaml


## Class exercise
Create a GitHub Actions workflow with three jobs:
	1.	Job 1 - Compare the contents of a file with a GitHub Actions repository variable. Fail if they differ.
	2.	Job 2 - Compare the contents of a different file directly with a GitHub Actions secret. Fail if they differ.
	3.	Job 3 - Run only if Jobs 1 and 2 succeed. Print the file value and variable value, and confirm success. Do not print the secret.

Requirements
	•	Use a multi-job workflow
	•	Use repository variables and secrets
	•	Use job dependencies (needs)
	•	Trigger the workflow with workflow_dispatch

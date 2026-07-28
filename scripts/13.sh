### Cloudwatch alarms, metrics and dashboards

### Cloudtrail event history VS trails


### Setup AWS cli
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
https://docs.aws.amazon.com/cli/latest/
export AWS_ACCESS_KEY_ID=XXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXX

# Run aws configure


#####################################################
################### SSM Parameter Store #############
#####################################################

1. String

aws ssm put-parameter \
    --region us-east-1 \
    --name "/dev/app/web_port" \
    --value "8080" \
    --type "String" \
    --overwrite

aws ssm get-parameter --region us-east-1 --name "/dev/app/web_port"

2. StringList

import boto3
ssm = boto3.client('ssm', region_name='us-east-1')

parameter_name = "/prod/network/allowed_cidrs"
parameter_values = "10.0.0.0/16,192.168.1.0/24,172.16.0.0/12"

print(f"--- Creating {parameter_name} ---")
ssm.put_parameter(
    Name=parameter_name,
    Value=parameter_values,
    Type='StringList',
    Overwrite=True
)

print(f"--- Retrieving {parameter_name} ---")
response = ssm.get_parameter(Name=parameter_name)

raw_value = response['Parameter']['Value']
print(f"Raw value from AWS: {raw_value}")

python_list = raw_value.split(',')
print(python_list)


3. SecureString

aws ssm put-parameter \
    --region us-east-1 \
    --name "/dev/db/password" \
    --value "SuperSecret123!" \
    --type "SecureString" \
    --overwrite

aws ssm get-parameter --region us-east-1 --name "/dev/db/password"
aws ssm get-parameter --region us-east-1 --name "/dev/db/password" --with-decryption


#####################################################
##################### Secrets Manager ###############
#####################################################

############ Create secret ############

aws secretsmanager create-secret \
    --region us-east-1 \
    --name "/dev/db/password" \
    --secret-string 'v1-SuperSecret123!'

# get
aws secretsmanager get-secret-value \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --query SecretString --output text

# override
aws secretsmanager put-secret-value \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --secret-string 'v2-NewSecret456!'

# get -> new value
aws secretsmanager get-secret-value \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --query SecretString --output text

# the old value is still there, under AWSPREVIOUS
aws secretsmanager get-secret-value \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --version-stage AWSPREVIOUS \
    --query SecretString --output text

# see both versions and their labels
aws secretsmanager list-secret-version-ids \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --query 'Versions[].{VersionId:VersionId,Stages:VersionStages}' \
    --output table

# rollback
aws secretsmanager update-secret-version-stage \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --version-stage AWSCURRENT \
    --move-to-version-id <UUID-of-AWSPREVIOUS> \
    --remove-from-version-id <UUID-of-AWSCURRENT>

# get -> back to the previous value
aws secretsmanager get-secret-value \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --query SecretString --output text



############ Rotate secret ############
# Create "sm-func" Lambda function

---
import boto3

sm = boto3.client("secretsmanager")

def lambda_handler(event, context):
    arn = event["SecretId"]
    token = event["ClientRequestToken"]
    step = event["Step"]

    if step == "createSecret":
        new_password = sm.get_random_password(
            PasswordLength=20, ExcludePunctuation=True
        )["RandomPassword"]
        sm.put_secret_value(
            SecretId=arn,
            ClientRequestToken=token,
            SecretString=new_password,
            VersionStages=["AWSPENDING"],
        )

    elif step == "finishSecret":
        stages = sm.describe_secret(SecretId=arn)["VersionIdsToStages"]
        current = next(v for v, s in stages.items() if "AWSCURRENT" in s)
        sm.update_secret_version_stage(
            SecretId=arn,
            VersionStage="AWSCURRENT",
            MoveToVersionId=token,
            RemoveFromVersionId=current,
        )
---

aws lambda add-permission \
    --region us-east-1 \
    --function-name sm-func \
    --statement-id secretsmanager-invoke \
    --action lambda:InvokeFunction \
    --principal secretsmanager.amazonaws.com

ROLE_ARN=$(aws lambda get-function-configuration \
    --region us-east-1 \
    --function-name sm-func \
    --query Role --output text)

aws iam attach-role-policy \
    --role-name "${ROLE_ARN##*/}" \
    --policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite

aws secretsmanager rotate-secret \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --rotation-lambda-arn arn:aws:lambda:us-east-1:762099405556:function:sm-func \
    --rotation-rules '{"ScheduleExpression":"rate(30 days)"}'

aws secretsmanager describe-secret \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --query '{Enabled:RotationEnabled,Lambda:RotationLambdaARN,Rules:RotationRules,Last:LastRotatedDate,Next:NextRotationDate}'

aws logs tail /aws/lambda/sm-func --region us-east-1 --since 5m --follow


# before
aws secretsmanager get-secret-value \
    --region us-east-1 --secret-id "/dev/db/password" \
    --query SecretString --output text

aws secretsmanager rotate-secret \
    --region us-east-1 --secret-id "/dev/db/password" --rotate-immediately

# after — new random value
aws secretsmanager get-secret-value \
    --region us-east-1 --secret-id "/dev/db/password" \
    --query SecretString --output text

# and the old one is still readable
aws secretsmanager get-secret-value \
    --region us-east-1 --secret-id "/dev/db/password" \
    --version-stage AWSPREVIOUS --query SecretString --output text


############ Replicate secret ############

aws secretsmanager replicate-secret-to-regions \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --add-replica-regions Region=eu-west-1

aws secretsmanager describe-secret \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --query ReplicationStatus

# read the replica — same name, different region
aws secretsmanager get-secret-value \
    --region eu-west-1 \
    --secret-id "/dev/db/password" \
    --query SecretString --output text

# replicas are read-only — this fails
aws secretsmanager put-secret-value \
    --region eu-west-1 \
    --secret-id "/dev/db/password" \
    --secret-string 'nope'

# write to the primary
aws secretsmanager put-secret-value \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --secret-string 'v3-replicated'

# and read it back from the replica a few seconds later
aws secretsmanager get-secret-value \
    --region eu-west-1 \
    --secret-id "/dev/db/password" \
    --query SecretString --output text


############ Delete secret ############

aws secretsmanager delete-secret \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --recovery-window-in-days 7

aws secretsmanager describe-secret \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --query '{Deleted:DeletedDate,Name:Name}'

# reads now fail
aws secretsmanager get-secret-value \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --query SecretString --output text
# InvalidRequestException: ... marked for deletion

# the failure every student hits — the name is still reserved
aws secretsmanager create-secret \
    --region us-east-1 \
    --name "/dev/db/password" \
    --secret-string 'x'
# InvalidRequestException: You can't create this secret because a secret with
# this name is already scheduled for deletion.

# undo
aws secretsmanager restore-secret \
    --region us-east-1 \
    --secret-id "/dev/db/password"

aws secretsmanager get-secret-value \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --query SecretString --output text

aws secretsmanager delete-secret \
    --region us-east-1 \
    --secret-id "/dev/db/password" \
    --force-delete-without-recovery
# name is free immediately; nothing to restore


#####################################################
########################### RDS #####################
#####################################################

# Create PostgreSQL RDS

SELECT datname FROM pg_database;
CREATE DATABASE school_db;
\c school_db

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    enrollment_date DATE DEFAULT CURRENT_DATE
);

INSERT INTO students (first_name, last_name)
VALUES ('Eli', 'Mutchnik');

SELECT * FROM students;


############ Create Layer ############

mkdir -p /tmp/layer/python
pip install psycopg2-binary --platform manylinux2014_aarch64 --python-version 3.14 --implementation cp --abi cp314 --only-binary=:all: --target /tmp/layer/python --no-deps
cd /tmp/layer && zip -rq layer.zip python
aws lambda publish-layer-version --layer-name psycopg2-py314-arm64 --zip-file fileb://layer.zip --compatible-runtimes python3.14 --compatible-architectures arm64
aws lambda update-function-configuration --function-name <your-function-name> --layers <new-arn-from-above> --region us-east-1


############ Create Function ############

import psycopg2
import os

def lambda_handler(event, context):
    conn = psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        connect_timeout=5,
    )
    with conn.cursor() as cur:
        cur.execute("SELECT 1")
        result = cur.fetchone()
    conn.close()
    return {"result": result}

### Cloudwatch alarms, metrics and dashboards

### Cloudtrail event history VS trails

### Secrets & Params
# SSM Parameter Store

1. String

aws ssm put-parameter \
    --name "/dev/app/web_port" \
    --value "8080" \
    --type "String" \
    --overwrite

aws ssm get-parameter --name "/dev/app/web_port"

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
    --name "/dev/db/password" \
    --value "SuperSecret123!" \
    --type "SecureString" \
    --overwrite

aws ssm get-parameter --name "/dev/db/password"
aws ssm get-parameter --name "/dev/db/password" --with-decryption


### Setup AWS cli
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
export AWS_ACCESS_KEY_ID=XXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXX


### RDS
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


### VPC

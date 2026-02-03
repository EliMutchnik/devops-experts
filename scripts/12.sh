import json
import os

def lambda_handler(event, context):
    # TODO implement
    print("We are learning Lambda!")
    print(event)
    print(os.environ)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!'),
        'event': event
    }



------------------------------------------------------------------------------------------------------
import json
import boto3

# Initialize the SQS client
sqs = boto3.client('sqs')

def lambda_handler(event, context):
    # Loop through the received messages
    for record in event['Records']:
        # Extract the message body
        message_body = record['body']
        receipt_handle = record['receiptHandle']
        
        # Process the message (for example, print the message)
        print(f"Received message: {message_body}")
        
        # Delete the message from the queue
        try:
            sqs.delete_message(
                QueueUrl='<YOUR_SQS_QUEUE_URL>',  # Replace with your SQS Queue URL
                ReceiptHandle=receipt_handle
            )
            print(f"Deleted message with receipt handle: {receipt_handle}")
        except Exception as e:
            print(f"Error deleting message: {str(e)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Messages processed and deleted successfully')
    }


---------------------------------------------------
import boto3
import os
from botocore.exceptions import ClientError

def get_secret(secret_name):
    # Initialize the boto3 client for Secrets Manager
    client = boto3.client('secretsmanager')
    
    try:
        # Call Secrets Manager to retrieve the secret value
        response = client.get_secret_value(SecretId=secret_name)
        
        # Secrets Manager response contains either 'SecretString' or 'SecretBinary'
        if 'SecretString' in response:
            return response['SecretString']
        else:
            # If the secret is binary, decode it
            return response['SecretBinary']
    
    except ClientError as e:
        print(f"Error retrieving secret: {e}")
        return None

def lambda_handler(event, context):
    
    # Get the secret content
    secret_value = get_secret("credentials")
    
    if secret_value:
        print(f"Secret retrieved successfully: {secret_value}")
        # Process the secret (e.g., database password, API keys, etc.)
        return {
            'statusCode': 200,
            'body': f"Secret retrieved: {secret_value[:50]}"  # Just printing the first 50 chars for security
        }
    else:
        return {
            'statusCode': 500,
            'body': 'Failed to retrieve the secret.'
        }

---------------------------------------------------
# It assumes your SQS message body is a JSON string (e.g., {"name": "Alice"}).
import json
import boto3
import os

# Initialize the DynamoDB resource outside the handler for connection reuse
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME', 'YourTableNameHere')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    for record in event['Records']:
        try:
            # 1. Parse the SQS message body
            body = json.loads(record['body'])
            name_value = body.get('name')
            
            if not name_value:
                print("No 'name' found in message body.")
                continue

            # 2. Write to DynamoDB
            table.put_item(
                Item={
                    'id': record['messageId'], # Using SQS ID as a unique primary key
                    'UserName': name_value
                }
            )
            print(f"Successfully processed name: {name_value}")
            
        except Exception as e:
            print(f"Error processing record: {e}")
            # Depending on your setup, you might want to re-raise 
            # to let SQS retry or move to a Dead Letter Queue
            continue

    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }

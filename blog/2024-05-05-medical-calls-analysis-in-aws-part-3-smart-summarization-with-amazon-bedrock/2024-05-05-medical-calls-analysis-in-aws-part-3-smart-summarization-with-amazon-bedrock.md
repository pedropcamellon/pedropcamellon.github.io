---
layout: default
title: "Medical Calls Analysis in AWS (Part 3) - Smart Summarization with Amazon Bedrock"
date: 2024-05-05
tags:
  [
    "aws",
    "amazon bedrock",
    "llm",
    "bedrock",
    "api",
    "lambda",
    "python",
    "transcribe",
    "html",
    "s3",
    "ai",
    "cloudwatch",
  ]
excerpt: "We'll summarize these files using the Titan model, an LLM hosted on Amazon Bedrock. This process shows how to transform lengthy conversations into concise, actionable summaries. Amazon Bedrock provides secure access to leading AI foundation models through a single API."
updated: 2025-05-17
---

Github Repo: [https://github.com/pedropcamellon/medical-calls-analysis-aws](https://github.com/pedropcamellon/medical-calls-analysis-aws)

## Introduction

In the previous article, we used Amazon Transcribe to obtain transcribed JSON files from audio recordings. Now, we'll summarize these files using the Titan model, an LLM hosted on Amazon Bedrock. This process shows how to transform lengthy conversations into concise, actionable summaries. Amazon Bedrock provides secure access to leading AI foundation models through a single API. Though we're focusing on medical applications, this approach works for any industry involving communication and information exchange—providing an efficient way to streamline information processing.

We'll combine AWS Lambda for serverless computing with Amazon Bedrock's language models to create an efficient solution that can process and analyze conversations at scale. The system uses S3 triggers to automatically initiate processing when new audio files are uploaded, demonstrating how to create a fully automated workflow for handling communication data. We'll cover everything from initial setup to implementation details.

## Create an Amazon S3 Bucket

We first need to create a storage bucket. Begin by logging into the AWS Management Console and navigate to the S3 service, either by searching for "S3" in the service search bar or selecting it from the "Storage" section. Once there, click on the "Create bucket" button. This will prompt you to provide details for the new bucket. Start by entering a unique name for your bucket in the "Bucket name" field and then select the Region in which you want your bucket to be located. The other settings can be left at their default values for now. After that, scroll down and click on the "Create bucket" button. Now your bucket is ready for use, and you can proceed to upload your files.

## Amazon Transcribe Permissions

To allow automatic transcription when new audio files are uploaded to our S3 bucket, we need to create an IAM role that gives Amazon Transcribe access to our audio files. This role requires the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": ["arn:aws:s3:::medical-calls-audio-bucket/*"]
    }
  ]
}
```

## Summarize Lambda Function Code

Now that we have our audio files and transcripts in S3, let's create a Lambda function to summarize the transcribed content using Amazon Bedrock. This function will process the JSON transcripts and generate concise summaries using a Large Language Model.

Here's how the summarization workflow operates:

1. A new transcript JSON file appears in the S3 'transcripts' folder
2. This triggers our summarization Lambda function
3. The function retrieves and processes the transcript
4. It sends the processed text to Amazon Bedrock
5. Bedrock analyzes the content and generates a summary
6. The summary is saved back to S3 in a 'summaries' folder

This automated approach ensures efficient processing of our transcripts. The Lambda function handles the entire workflow: reading the JSON transcript, formatting the content for the LLM, making the API call to Bedrock, and storing the results. The function includes error handling and logging to track any issues that may arise during processing.

Let's examine how this Lambda function works in detail. When triggered by a new transcript file, it reads the JSON content from S3 and extracts the relevant conversation data. It then formats this data into a prompt suitable for the Bedrock model. After receiving the model's response, it processes the summary and saves it back to S3. The function includes comprehensive error handling and returns appropriate status messages to confirm successful execution or alert of any issues.

```python
import boto3
import json

def lambda_handler(event, context):
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]

    print(f"Processing file {key} from bucket {bucket}.")

    # One of a few different checks to ensure we don't end up in a recursive loop.
    if ".json" not in key:
        print("This demo only works with transcription JSON files.")
        return {
            "statusCode": 400,
            "body": json.dumps("This demo only works with transcription JSON files."),
        }

    # Create a Boto3 client for the S3 service
    s3_client = boto3.client("s3", region_name="us-east-1")
    bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")

    try:
        response = s3_client.get_object(Bucket=bucket, Key=key)

        file_content = response["Body"].read().decode("utf-8")

        transcript = extract_transcript_from_textract(file_content)

        print(f"Successfully read file {key} from bucket {bucket}.")

        print(f"Transcript: {transcript}")

        summary = bedrock_summarisation(transcript, bedrock_client)

        print(f"Summary: {summary}")

        filename = (
            key.split("/")[-1]
            .replace("transcription-job", "summarization-job")
            .replace(".json", ".txt")
        )

        # Create the summary key with proper path
        summary_key = f"summaries/{filename}"

        s3_client.put_object(
            Bucket=bucket, Key=summary_key, Body=summary, ContentType="text/plain"
        )

        print(f"Summary file {summary_key} created in bucket {bucket}.")

    except Exception as e:
        print(f"Error occurred: {e}")
        return {"statusCode": 500, "body": json.dumps(f"Error occurred: {e}")}

    return {
        "statusCode": 200,
        "body": json.dumps(
            f"Successfully summarized {key} from bucket {bucket}. Summary: {summary}"
        ),
    }
```

## Parsing the Transcript

The transcript service generates JSON output that details each spoken word and punctuation mark. The extraction function streamlines this data by parsing the main text, matching speaker segments, formatting with speaker labels, and incorporating timestamps and punctuation marks. Let's break down its structure:

- **jobName**: A unique identifier for the transcription job (e.g., "transcription-job-abc78294-bfb4-4f22-ad8a-d3b26d5329cd")
- **status**: The current state of the transcription job (e.g., "COMPLETED")
- **results.transcripts**: Contains the full text transcript as a single string
- **speaker_labels.segments**: Information about who is speaking and when
- **start_time/end_time**: Timestamps showing when each segment was spoken

```json
{
  "jobName": "transcription-job-abc78294-bfb4-4f22-ad8a-d3b26d5329cd",
  "accountId": "400513684195",
  "status": "COMPLETED",
  "results": {
    "transcripts": [
      {
        "transcript": "Good morning, Dr Hayes's office. Tarn speaking. Hi, good morning. This is Ernesto Sanchez. The doctor told me I need to come in today for my heart, but I forgot to make an appointment and I don't have it right. Anyway. Ok, Mr Sanchez, what is your date of birth? 03 2576. And when were you last seen last week in the hospital? Can you hold for?"
      }
    ],
    "speaker_labels": {
      "segments": [
        {
          "start_time": "0.689",
          "end_time": "3.74",
          "speaker_label": "spk_0",
          "items": [
            {
              "speaker_label": "spk_0",
              "start_time": "0.699",
              "end_time": "0.97"
            },
            {
              "speaker_label": "spk_0",
              "start_time": "0.98",
              "end_time": "1.379"
            },
            ...
```

The `extract_transcript_from_textract` function transforms the raw JSON output from Amazon Textract into a human-readable conversation format. It processes the transcript word by word, organizing the content by speaker and maintaining proper formatting. The function adds speaker labels at the beginning of each new speaker's dialogue, handles punctuation by removing trailing spaces, and combines all elements into a clean, formatted transcript with clear speaker transitions. This transformation makes the conversation much easier to read and analyze compared to the raw JSON format.

```python
def extract_transcript_from_textract(file_content):
    transcript_json = json.loads(file_content)

    output_text = ""
    current_speaker = None

    items = transcript_json["results"]["items"]

    # Iterate through the content word by word:
    for item in items:
        speaker_label = item.get("speaker_label", None)
        content = item["alternatives"][0]["content"]

        # Start the line with the speaker label:
        if speaker_label is not None and speaker_label != current_speaker:
            current_speaker = speaker_label
            output_text += f"\n{current_speaker}: "

        # Add the speech content:
        if item["type"] == "punctuation":
            output_text = output_text.rstrip()  # Remove the last space

        output_text += f"{content} "

    return output_text

```

This is the resulting file after the transcription and formatting process. It has been transformed into a more concise and readable format, making it easier to understand. Each speaker's dialogue is clearly labeled and separated, allowing for easy identification of the conversation flow between the different speakers.

```
spk_0: Good morning, Dr Hayes's office. Tarn speaking. Hi,
spk_1: good morning. This is Ernesto Sanchez. The doctor told...
spk_0: Ok, Mr Sanchez, what is your date of birth?
spk_1: 03 2576. And when were you
spk_0: last seen last
spk_1: week in the hospital?
spk_0: Can you hold for?
```

## **Transcript Summarization**

To interact with the Bedrock service, we need to set up a Bedrock runtime client. This is accomplished by creating an instance of the Bedrock service in a specific AWS region. In this case, we're using the 'us-east-1' region.

```python
bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-east-1')
```

We pass the transcript to the `bedrock_summarisation` function for processing. The function wraps the transcript in XML-like tags and creates a custom prompt that requests specific output formatting, including sentiment analysis and issue identification. It then sets up the API call with key parameters such as the model selection (amazon.titan-text-express-v1), token limits, and temperature settings to control the AI's response. Finally, it sends the request through the Bedrock client, extracts the summary text from the JSON response, and returns the summarized content.

```python
def bedrock_summarisation(transcript, bedrock_client):
    """
    Summarizes a conversation transcript using Amazon Bedrock.

    This function reads a prompt template from a file, fills it with the provided
    transcript and predefined topics, and sends it to the Amazon Bedrock model for
    text generation. The function then retrieves and returns the generated summary
    text.

    :param transcript: The conversation transcript to be summarized.
    :param bedrock_client: A client for invoking the Amazon Bedrock text generation model.
    :return: A summary of the conversation generated by the Bedrock model.
    """

    print("Starting Bedrock summarization...")

    prompt = f"""I need to summarize a conversation. The transcript of the
        ...
        """

    kwargs = {
        "modelId": "amazon.titan-text-express-v1",
        "contentType": "application/json",
        "accept": "*/*",
        "body": json.dumps(
            {
                "inputText": prompt,
                "textGenerationConfig": {
                    "maxTokenCount": 2048,
                    "stopSequences": [],
                    "temperature": 0,
                    "topP": 0.9,
                },
            }
        ),
    }

    response = bedrock_client.invoke_model(**kwargs)

    summary = (
        json.loads(response.get("body").read()).get("results")[0].get("outputText")
    )

    return summary
```

This prompt utilizes several key prompt engineering techniques to ensure clear and structured output from the language model. First, it employs XML-like tags (<data>) to clearly delineate the input transcript, helping the model distinguish between instructions and content. Second, it provides explicit output formatting requirements through a JSON schema, which constrains the model's response to a specific structure. Third, it uses categorical constraints for the "topic" field by providing predefined options (["charges"|"location"|"availability"]), limiting potential responses to these specific categories. Finally, it breaks down the analysis requirements into distinct components (sentiment and issues), making the task more manageable and ensuring all required elements are addressed in the response.

```python
prompt = f"""I need to summarize a conversation. The transcript of the
        conversation is between the <data> XML like tags.

        <data>
        {transcript}
        </data>

        The summary must contain a one word sentiment analysis, and
        a list of issues, problems or causes of friction
        during the conversation.

        The output must be provided in JSON format using the following fields:

        - "sentiment": <sentiment>,
        - "issues": [
                - "topic": ["charges"|"location"|"availability"]
                - "summary": [issue_summary]
            ]
        """
```

## Creating the Lambda Function

Following the same steps explained in the previous article for creating Lambda functions through the AWS Console, we'll create a new function called `summarize_lambda`. This function will be responsible for handling the summarization process of our transcribed conversations using Amazon Bedrock.

![]()

Before testing the function, we need to update the IAM role permissions to allow the Lambda function to interact with Amazon Bedrock services. Specifically, we need to grant two key permissions:

1. "bedrock:InvokeModel" - This allows the Lambda function to make API calls to run inference using Bedrock's AI models
2. "bedrock:ListModels" - This enables the function to retrieve information about available Bedrock models

Add these permissions to your IAM role policy:

```json
{
  "Effect": "Allow",
  "Action": [
    "bedrock:InvokeModel",
    "bedrock:ListModels"
  ],
  "Resource": "*"
},
```

### Increasing Lambda Timeout

When working with Amazon Bedrock for text generation, it's important to note that the model can take several seconds to process and return a response. By default, AWS Lambda functions have a timeout of 3 seconds, which is insufficient for this use case. The Lambda function needs to be configured with appropriate timeout and memory settings to accommodate the Bedrock API response time. To update the Lambda configuration in the AWS Console:

1. Go to the AWS Lambda console
2. Select your function
3. Go to the "Configuration" tab
4. Click on "General configuration"
5. Click "Edit"
6. Increase the timeout to at least 30 seconds
7. Increase the memory to at least 256 MB
8. Click "Save"

After making these changes, the function should complete successfully. Monitor the CloudWatch logs to see the detailed execution progress.

![]()

## Setting Up S3 Event Notifications

To automate the process, we'll set up S3 to trigger our Lambda function when new transcript is available. To set up S3 event notifications through the AWS Management Console:

1. Navigate to your S3 bucket and select the "Properties" tab
2. Scroll down to find the "Event Notifications" section and click "Create event notification"
3. Configure the event settings:
   - Event name: Enter a descriptive name (e.g., "TranscriptFileTrigger")
   - Prefix: Enter "transcripts/" to limit the trigger to files in this folder
   - Suffix: Enter ".json" to only trigger on JSON files
   - Event types: Select "All object create events"
4. Under "Destination", select "Lambda function" and choose your transcription function from the dropdown
5. Click "Save changes" to create the event notification

![]()

Once you configure the S3 event notification to trigger your Lambda function, you’ll see the trigger listed in your Lambda function’s configuration. There’s no need to add it again in the Lambda console-this single step establishes the connection, and your workflow is ready to go.

![]()

## Upload an Audio File to the Bucket

To upload an audio file to your S3 bucket through the AWS Management Console, follow these steps:

1. Open the AWS Management Console and navigate to the S3 service
2. Click on your bucket name from the list of buckets
3. Click the "Upload" button at the top of the bucket contents list
4. Click "Add files" or drag and drop your audio file (in this case, phone_call.mp3) into the upload area
5. Review the default settings for the upload. For basic uploads, the default settings are usually sufficient
6. Click "Upload" to start the file transfer

Once the upload is complete, you'll see your audio file listed in the bucket contents. The S3 event notification we configured earlier will automatically trigger the Lambda function to start the transcription process.

![]()

![]()

## **Conclusions**

In this article, we demonstrated how to build a serverless system for conversation summarization using AWS Lambda and Amazon Bedrock. We explored effective prompt engineering techniques using XML-like tags and structured outputs, while creating a simple yet extensible event-driven architecture using S3 triggers. This foundation serves as a starting point for more sophisticated data processing workflows, with detailed coverage of the necessary configurations for IAM permissions, Lambda settings, and event notifications.

In the next article of this series, we'll explore how to monitor our system's performance, track usage patterns, detect anomalies, and implement safeguards for LLM responses. We'll focus on creating a robust monitoring framework to ensure our application operates reliably and securely.

## Sources

- [https://docs.aws.amazon.com/lambda/latest/dg/concepts-event-driven-architectures.html](https://docs.aws.amazon.com/lambda/latest/dg/concepts-event-driven-architectures.html)
- [https://programming.am/setting-up-aws-lambda-timeouts-and-memory-limits-fa19f4164a07](https://programming.am/setting-up-aws-lambda-timeouts-and-memory-limits-fa19f4164a07)

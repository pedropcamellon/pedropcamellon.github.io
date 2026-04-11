---
layout: default
title: "Medical Calls Analysis in AWS (Part 5) - Automating AWS Deployments with Terraform"
date: 2024-07-02
tags: ["aws", "terraform", "infrastructure-as-code", "serverless", "devops"]
image: "aws_bedrock.webp"
is_new: true
excerpt: "Learn how to automate AWS resource provisioning and management using Terraform. This guide covers version-controlled infrastructure, consistent deployments, and error-free configuration."
---

Github Repo: https://github.com/pedropcamellon/medical-calls-analysis-aws

# Summary

- **Terraform as Infrastructure as Code:** Automates AWS resource deployment with declarative code, eliminating manual configuration and ensuring consistency.
- **Improved Deployment Process:** Makes infrastructure deployments consistent, efficient, and scalable while reducing human error.
- **Structured Project Organization:** Uses dedicated files for configuration (`main.tf`), variables (`variables.tf`), and outputs (`outputs.tf`) to maintain clean, modular code.
- **Security-Focused IAM Policies:** Implements least-privilege access control for Lambda functions with precise S3, Transcribe, and Bedrock permissions.
- **Event-Driven Architecture:** Leverages S3 notifications to create a decoupled serverless pipeline that independently triggers transcription and summarization functions.
- **Environment Management:** Supports multiple environments (development, staging, production) through workspaces with environment-specific variables.
- **Resource Lifecycle Control:** Provides complete infrastructure lifecycle management from creation to destruction with simple commands.

# Introduction

In the previous post of our series, we explored the importance of monitoring and logging in AI applications using CloudWatch. Now, we'll take a step further by introducing Terraform, an Infrastructure as Code (IaC) tool, to automate the deployment of our serverless architecture.

Terraform, developed by HashiCorp, is an open-source tool that lets you define and provision cloud infrastructure using HCL (HashiCorp Configuration Language), a declarative configuration language. As a powerful Infrastructure as Code (IaC) solution, it moves beyond traditional scripts and web interfaces—you simply describe _what_ you want your infrastructure to look like, and Terraform determines _how_ to make it happen.

Manually configuring AWS resources through the Console can be tedious, error-prone, and hard to scale. Terraform lets you define your entire infrastructure in code, making deployments:

- **Consistent:** Infrastructure definitions are version-controlled and repeatable, reducing configuration drift. When connected to version control systems like GitHub or GitLab, HCP Terraform can automatically propose infrastructure changes based on your code commits.
- **Efficient:** Changes are tracked, reviewed, and applied automatically, minimizing manual errors.
- **Scalable:** Easily replicate environments for development, staging, or production with minimal effort.

**Key concepts:**

- **Declarative Language:** You specify what infrastructure you want (the "desired state") rather than writing step-by-step instructions on how to create it. Terraform figures out the necessary steps to achieve that state.
- **Providers:** These are plugins that enable Terraform to interact with various cloud platforms and services. The AWS provider, which we'll use, allows Terraform to create and manage AWS resources.
- **State Management:** Terraform maintains a state file that tracks all resources it manages. This helps Terraform understand what resources exist and how to modify them when configurations change.
- **Plan and Apply:** Terraform follows a two-step process:
  - First, it creates an execution plan showing what changes it will make
  - Then, after approval, it applies those changes to create or modify the infrastructure

For our medical call analysis system, Terraform will automate the deployment of several key AWS resources. This includes creating S3 buckets for storing audio files and transcripts, deploying Lambda functions with appropriate permissions and configurations, and setting up IAM roles and policies to ensure secure access to AWS services. We'll also configure CloudWatch for comprehensive monitoring and logging, allowing us to maintain visibility into our system's performance. One of the biggest advantages of using Terraform is its ability to manage all these resources in a version-controlled, repeatable way, making it easy to spin up or tear down complete environments for testing and scaling.

Let's dive into how we can use this incredible tool to automate the deployment of all the AWS resources needed for our medical call analysis system!

# Project Structure and Prerequisites

Before getting started with this tutorial, you'll need to set up your development environment. This includes having the AWS CLI configured with appropriate credentials and Python 3.11 installed for Lambda development. You'll also need an AWS account with the necessary permissions to create resources. To authenticate the Terraform AWS provider, you'll need to set up your IAM credentials by exporting your AWS access key ID and secret key as environment variables:
`$ export AWS_ACCESS_KEY_ID=`
`$ export AWS_SECRET_ACCESS_KEY=`

# **Install Terraform**

To install Terraform, you can download it as a binary package from HashiCorp's website or use popular package managers. The installation process involves downloading the appropriate package for your system as a zip archive, extracting it to get the single `terraform` binary, and adding it to your system's PATH.

For Windows users, you can set up the PATH by navigating to `Control Panel -> System -> System settings -> Environment Variables`, finding the PATH variable, and adding the directory containing the terraform binary (remember to include a semicolon as a delimiter between paths). After installation, you'll need to launch a new console for the changes to take effect.

Verify that the installation worked by opening a new terminal session and listing Terraform's available subcommands.

```bash
$ terraform -help
Usage: terraform [-version] [-help] <command> [args]

The available commands for execution are listed below.The most common, useful commands are shown first, followed byless common or more advanced commands. If you're just gettingstarted with Terraform, stick with the common commands. For theother commands, please read the help and docs before usage.
##...
```

Add any subcommand to `terraform -help` to learn more about what it does and available options.

```bash
$ terraform -help plan
```

# **Write configuration**

With Terraform installed, you are ready to create your first infrastructure.

The set of files used to describe infrastructure in Terraform is known as a Terraform *configuration*. You will write your first configuration to define a single AWS EC2 instance.

A Terraform configuration requires its own dedicated working directory with a specific file structure. The main configuration consists of three key files: `main.tf` for the primary infrastructure configuration, `variables.tf` for defining input variables, and `outputs.tf` for specifying output values. This organized structure helps maintain clean, modular, and reusable infrastructure code that can be easily deployed with Terraform.

# **Terraform Block**

The `terraform {}` block contains Terraform settings, including the required providers Terraform will use to provision your infrastructure. For each provider, the `source` attribute defines an optional hostname, a namespace, and the provider type. Terraform installs providers from the [Terraform Registry](https://registry.terraform.io/) by default. In this example configuration, the `aws` provider's source is defined as `hashicorp/aws`, which is shorthand for `registry.terraform.io/hashicorp/aws`.

You can also set a version constraint for each provider defined in the `required_providers` block. The `version` attribute is optional, but we recommend using it to constrain the provider version so that Terraform does not install a version of the provider that does not work with your configuration. If you do not specify a provider version, Terraform will automatically download the most recent version during initialization.

```hcl
terraform {
	# ...

  required_version = ">= 1.11.4"
}
```

To learn more, reference the [provider source documentation](https://developer.hashicorp.com/terraform/language/providers/requirements).

# **Providers**

The `provider` block configures the AWS provider, which is a plugin that Terraform uses to create and manage AWS resources. For our medical call analysis system, we'll use the AWS provider to manage resources like Lambda functions, S3 buckets, and IAM roles. The provider block specifies configuration details like region and authentication settings.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.96"
    }
  }

  required_version = ">= 1.11.4"
}
```

# Variables

Separating variables into their own file is a Terraform best practice that enhances code organization and reusability. The `variables.tf` file serves as a central location for all variable definitions, making it easier to:

- **Maintain configuration:** Keep infrastructure code clean and organized by separating variable declarations from their usage
- **Reuse configurations:** Share and reuse infrastructure code across different environments by simply changing variable values
- **Document infrastructure:** Use description fields to document what each variable is for

Here's how we define our variables in `variables.tf`:

```hcl
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to store audio files and results"
  type        = string
  default     = "medical-calls-audio-bucket"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "Production"
}

variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "python3.11"
}

variable "transcribe_lambda_timeout" {
  description = "Timeout in seconds for transcribe Lambda function"
  type        = number
  default     = 10
}

variable "summarize_lambda_timeout" {
  description = "Timeout in seconds for summarize Lambda function"
  type        = number
  default     = 30
}
```

Each variable declaration includes:

- **Description:** Explains the purpose of the variable
- **Type:** Specifies the variable type (string, number, bool, etc.)
- **Default:** Provides a default value if none is specified

You can override these default values in several ways:

- Using a `terraform.tfvars` file
- Setting environment variables (TF_VAR_variable_name)
- Using command-line flags (-var or -var-file)

# **Resources**

Use `resource` blocks to define components of your infrastructure. A resource might be a physical or virtual component such as an EC2 instance, or it can be a logical resource such as a Heroku application.

Resource blocks have two strings before the block: the resource type and the resource name. In this example, the resource type is `aws_instance` and the name is `app_server`. The prefix of the type maps to the name of the provider. In the example configuration, Terraform manages the `aws_instance` resource with the `aws` provider. Together, the resource type and resource name form a unique ID for the resource. For example, the ID for your EC2 instance is `aws_instance.app_server`.

Resource blocks contain arguments which you use to configure the resource. Arguments can include things like machine sizes, disk image names, or VPC IDs. Our [providers reference](https://developer.hashicorp.com/terraform/language/providers) lists the required and optional arguments for each resource. For your EC2 instance, the example configuration sets the AMI ID to an Ubuntu image, and the instance type to `t2.micro`, which qualifies for AWS' free tier. It also sets a tag to give the instance a name.

## S3 Bucket Configuration

We create an S3 bucket to store our audio files and transcripts:

```hcl
resource "aws_s3_bucket" "audio_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "Medical Calls Audio Bucket"
    Environment = var.environment
  }
}
```

## IAM Roles and Policies

Our IAM configuration follows security best practices for handling medical data by implementing strict access controls. We follow the principle of least privilege by granting Lambda functions only the essential permissions needed for their operations: S3 object access, Transcribe job execution, and Bedrock model invocation. The policies are carefully crafted to restrict actions to specific resources, such as limiting `s3:GetObject` operations to the `medical-calls-audio-bucket`, and we avoid using broad permissions like `"Resource": "*"`.

To implement secure IAM permissions, we begin by creating dedicated execution roles for our Lambda functions. These roles form the foundation of our security architecture by establishing a trust relationship through an assume role policy document. This JSON document explicitly grants the Lambda service permission to assume the role, creating a secure base upon which we can build more granular permissions through additional policy attachments. Following AWS best practices for serverless applications, these roles precisely define which AWS services and resources our Lambda functions can access.

```hcl
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}
```

After establishing the foundational trust relationship through the execution role, we now create specific IAM policies to define the exact permissions our Lambda functions need. These policies follow the principle of least privilege by carefully restricting actions to specific resources. For example, S3 access is limited to specific operations on our medical-calls-audio-bucket, and we explicitly avoid using overly permissive wildcards like "Resource": "\*".

Let's implement these scoped permissions for S3, Amazon CloudWatch, Amazon Transcribe, and Amazon Bedrock services:

```hcl
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda to access S3, Transcribe, and Bedrock"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.audio_bucket.arn}",
        "${aws_s3_bucket.audio_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "transcribe:StartTranscriptionJob",
        "transcribe:GetTranscriptionJob",
        "transcribe:ListTranscriptionJobs"
      ],
      "Resource": "arn:aws:transcribe:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:ListModels"
      ],
      "Resource": [
        "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-text-express-v1"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.transcribe_lambda.function_name}:*",
        "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.summarize_lambda.function_name}:*"
      ]
    }
  ]
}
EOF
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
```

After creating the IAM policy, we attach it to our Lambda execution role. This attachment grants our Lambda functions the specific permissions they need to operate securely.

```hcl

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
```

## Lambda Functions

Our Lambda functions are optimized for AI workloads through careful runtime and configuration choices. We use Python 3.11 as it provides an optimal balance between machine learning library support and cold-start performance, with Lambda Layers handling dependencies like Boto3. The timeout settings are tailored to each function's needs: the Transcription Lambda has a 10-second timeout for efficient audio upload processing, while the Summarization Lambda is allocated 30 seconds to accommodate Bedrock's AI processing requirements. The system is built around two core functions: a Transcribe Lambda that handles audio file transcription, and a Summarize Lambda that processes transcripts using Bedrock.

```hcl

# Lambda Function for Transcription
resource "aws_lambda_function" "transcribe_lambda" {
  function_name = "transcribe_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_transcribe.lambda_handler"
  runtime       = var.lambda_runtime

  timeout = var.transcribe_lambda_timeout

  # Path to your Lambda deployment package
  filename         = "../lambda_transcribe.zip"
  source_code_hash = filebase64sha256("../lambda_transcribe.zip")
}

# Lambda Function for Summarization
resource "aws_lambda_function" "summarize_lambda" {
  function_name = "summarize_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_summarize.lambda_handler"
  runtime       = var.lambda_runtime

  timeout = var.summarize_lambda_timeout

  # Path to your Lambda deployment package
  filename         = "../lambda_summarize.zip"
  source_code_hash = filebase64sha256("../lambda_summarize.zip")
}
```

## **Event-Driven Pipeline**

Our system leverages S3 event notifications to create an efficient serverless pipeline. When files are uploaded to specific paths (audios/ and transcripts/), they automatically trigger corresponding Lambda functions for transcription and summarization. This architecture employs a decoupled approach, where transcription and summarization processes run as independent Lambda functions. This separation not only prevents cascading failures but also enables parallel scaling, making the system more resilient and performant. The workflow is straightforward: uploading new audio files triggers the transcription function, while the resulting transcripts automatically trigger the summarization function.

```hcl
# S3 Bucket Notification for Transcription Lambda
resource "aws_s3_bucket_notification" "audio_bucket_notification" {
  bucket = aws_s3_bucket.audio_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transcribe_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "audios/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.summarize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "transcripts/"
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke_transcribe, aws_lambda_permission.allow_s3_to_invoke_summarize]
}
```

These Lambda permissions are crucial for enabling S3 to trigger our Lambda functions. The `aws_lambda_permission` resources establish the necessary trust relationship between S3 and Lambda, allowing S3 to invoke our functions when specific events occur.

For the transcription Lambda:

- The `statement_id` provides a unique identifier for this permission
- The `action` specifies that S3 can invoke the Lambda function
- The `principal` identifies S3 as the AWS service that's allowed to use this permission
- The `source_arn` restricts the permission to only our specific S3 bucket

This security configuration follows AWS best practices by implementing the principle of least privilege, ensuring that our S3 bucket can only invoke the specific Lambda functions we've designated, and only for the intended purposes of our medical calls analysis system.

```hcl

# Allow S3 to invoke the Transcription Lambda
resource "aws_lambda_permission" "allow_s3_to_invoke_transcribe" {
  statement_id  = "AllowS3InvokeTranscribe"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transcribe_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.audio_bucket.arn
}

# Allow S3 to invoke the Summarization Lambda
resource "aws_lambda_permission" "allow_s3_to_invoke_summarize" {
  statement_id  = "AllowS3InvokeSummarize"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.summarize_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.audio_bucket.arn
}
```

# Outputs

To maintain a clean and organized Terraform configuration, it's recommended to define outputs in a separate file called `outputs.tf`. This separation helps in:

- Better code organization and maintainability
- Easier documentation of outputs
- Clear visibility of what information is exported from the Terraform project

In our case, we export:

- The S3 bucket name - useful for referencing in deployment scripts or other systems
- Lambda function ARNs - needed for setting up additional triggers or integrations

These outputs can be queried using `terraform output` command or referenced by other Terraform configurations when using this as a module.

The values are only known after the resources are created, making them valuable for subsequent automation steps or documentation purposes.

```hcl
output "s3_bucket_name" {
  value = aws_s3_bucket.audio_bucket.bucket
}

output "transcribe_lambda_arn" {
  value = aws_lambda_function.transcribe_lambda.arn
}

output "summarize_lambda_arn" {
  value = aws_lambda_function.summarize_lambda.arn
}
```

# **Initialize the directory**

Before working with a new Terraform configuration or checking out an existing one from version control, you must first run `terraform init` to initialize the directory. This command downloads and installs the necessary providers (in this case, the AWS provider) and stores them in a hidden `.terraform` subdirectory. Additionally, it creates a `.terraform.lock.hcl` lock file that specifies the exact provider versions being used, allowing you to maintain control over provider updates for your project.

```bash
$ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching...
```

# **Format and validate the configuration**

Before deploying your Terraform configuration, it's important to ensure proper formatting and validation. The `terraform fmt` command helps maintain consistent formatting across all configuration files, automatically updating them for readability.

After formatting, use `terraform validate` to verify that your configuration is syntactically valid and internally consistent. If both commands run successfully, with `terraform fmt` showing no modifications needed and `terraform validate` returning a success message, your configuration is ready for deployment.

# **Create infrastructure**

Apply the configuration now with the `terraform apply` command. Terraform will print output similar to what is shown below. We have truncated some of the output to save space.

Before it applies any changes, Terraform prints out the *execution plan* which describes the actions Terraform will take in order to change your infrastructure to match the configuration.

The output format is similar to the diff format generated by tools such as Git. The output has a `+` next to `aws_instance.app_server`, meaning that Terraform will create this resource. Beneath that, it shows the attributes that will be set. When the value displayed is `(known after apply)`, it means that the value will not be known until the resource is created. For example, AWS assigns Amazon Resource Names (ARNs) to instances upon creation, so Terraform cannot know the value of the `arn` attribute until you apply the change and the AWS provider returns that value from the AWS API.

Terraform will now pause and wait for your approval before proceeding. If anything in the plan seems incorrect or dangerous, it is safe to abort here before Terraform modifies your infrastructure.

In this case the plan is acceptable, so type `yes` at the confirmation prompt to proceed. Executing the plan will take a few minutes since Terraform waits for the EC2 instance to become available.

```bash
$ terraform apply
Terraform used the selected providers to generate the following execution plan.Resource actions are indicated with the following symbols:  + createTerraform will perform the following actions:
# ...
Do you want to perform these actions?
Terraform will perform the actions described above.  Only 'yes' will be accepted to approve. Enter a value:
```

We have now created our infrastructure using Terraform! After deployment, verify the setup by:

- Uploading a test audio file to the S3 bucket
- Checking CloudWatch logs for Lambda execution
- Verifying the generated transcript and summary in the respective S3 folders

# **Inspect state**

After applying your configuration, Terraform maintains a state file called `terraform.tfstate` that tracks resource IDs, properties, and management details. Since this file contains sensitive information and is crucial for resource management, it requires secure storage and restricted access. For production environments, we recommend using remote state storage solutions like HCP Terraform, Terraform Enterprise, or other supported remote backends. You can examine your current state configuration using the `terraform show` command.

```bash
$ terraform show
# data.aws_caller_identity.current:
data "aws_caller_identity" "current" {
    account_id = "400513684195"
    arn        = "arn:aws:iam::400513684195:user/pedro-dev"
    id         = "400513684195"
    user_id    = "AIDAV2QDZ2LR4XE25T7PZ"
}

# aws_iam_policy.lambda_policy:
resource "aws_iam_policy" "lambda_policy" {
    arn              = "arn:aws:iam::400513684195:policy/lambda_policy"
    attachment_count = 1
    description      = "Policy for Lambda to access S3, Transcribe, and Bedrock"
# ...
```

When Terraform created this EC2 instance, it also gathered the resource's metadata from the AWS provider and wrote the metadata to the state file. In later tutorials, you will modify your configuration to reference these values to configure other resources and output values.

# Clean Up

To clean up after testing, you can easily remove all deployed resources by running the `terraform destroy` command. This makes it cost-effective to experiment with different configurations since you can quickly tear down resources when they're no longer needed.

After running the destroy command, it's recommended to verify in the AWS Console that all resources (S3 buckets, Lambda functions, IAM roles, etc.) have been properly deleted. This infrastructure-as-code approach makes it simple to recreate the entire system later when needed, using the same configuration files.

```hcl
terraform destroy
```

# **Operational Excellence with Terraform**

## **Environment Management**

Terraform workspaces provide a powerful way to manage multiple environments (development, staging, production) using the same configuration files. Each workspace maintains its own state file, allowing you to keep infrastructure separate while reusing code. Environment-specific variables are managed through `terraform.tfvars` files, making it easy to customize settings like instance sizes or backup frequencies for each environment.

## **Resource Organization and Cost Control**

Implementing a consistent tagging strategy is crucial for resource management and cost optimization. By adding tags such as `Environment = "Production"`, `Team = "DevOps"`, or `Project = "MedicalCalls"`, you can:

- Generate detailed cost allocation reports by team or project
- Identify and optimize underutilized resources
- Automate resource cleanup and maintenance tasks
- Track resource ownership and purpose across your organization

# **Conclusions**

In this post, we demonstrated how Terraform solves key infrastructure management challenges through Infrastructure as Code (IaC). By automating AWS resource provisioning and management, Terraform eliminates manual configuration errors, ensures consistent deployments, and enables version control of infrastructure. Its declarative approach not only simplifies resource creation and updates but also provides a reliable way to track, modify, and destroy infrastructure across multiple environments.

# Sources

- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows
- https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/security.html
- https://aws.amazon.com/blogs/security/techniques-for-writing-least-privilege-iam-policies/
- https://www.vantage.sh/blog/terraform-automate-cost-tags

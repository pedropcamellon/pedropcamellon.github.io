---
layout: default
title: "Trading Decoupling for Observability: Voice Notes Transcription in an EHR"
date: 2026-04-16
tags:
  [
    "architecture",
    "distributed-systems",
    "temporal",
    "healthcare",
    "aws",
    "python",
    "orchestration",
  ]
image: "folium-ehr-temporal.png"
is_new: true
excerpt: "I added a voice notes transcription pipeline to Folium EHR and built it as an orchestrated workflow. Event-driven worked for me on AWS/Azure, but once the workflow grew the debugging tax was stitching logs and correlation IDs across services. Orchestration gave me one place to see job state end-to-end, step-level retries, and clear visibility into what's running or failed."
---

<div class="tldr">

I added a voice notes transcription pipeline to Folium EHR and built it as an orchestrated workflow. Event-driven worked for me on AWS/Azure, but once the workflow grew the debugging tax was stitching logs and correlation IDs across services. Orchestration gave me one place to see job state end-to-end, step-level retries, and clear visibility into what's running or failed. Temporal was the engine, but the decision was about the model. For this feature, I traded some decoupling for better observability, step-level retries, and durability.

</div>

Folium EHR is my project to build a modern electronic health record, and voice notes are one of the fastest ways to capture clinical notes. To reduce that documentation burden, I added a voice notes transcription pipeline. I’m trying the project to stay cloud-agnostic: deployable to AWS, Azure, or on‑prem. I wanted voice notes to follow that same pattern.

I’d built event-driven pipelines before on AWS and Azure, and I knew the debugging cost once the workflow grows. I’d stitch correlation IDs across logs and queues just to see whether a workflow completed. Then I’d have to decide if (and when) to retry, without a clear view of what had already succeeded.

I needed real-time transcription, but with workflow-grade visibility: end-to-end state, step-level retries, and traceable logs. Orchestration matched that. Temporal is the engine I used, but the decision was about the model.

In practice the flow is simple: the browser records audio and sends it to the backend. Storage depends on where Folium is deployed: **S3 on AWS**, **Blob Storage on Azure**, and **MinIO on‑prem**. The backend (FastAPI) stores the file, then starts a Temporal workflow and passes metadata like a presigned URL. A worker picks up the task, transcribes the audio, and when the transcript is ready I overwrite the encounter note. The UI polls until it sees the update. It’s not push-based yet, but it kept the feature responsive and fast to ship.

That design bought me three operational wins:

- **One job state per recording.** One place to look.
- **Retries per step.** Retry what failed, don’t replay the pipeline.
- **Visibility.** Running/failed/where in one nice UI.

One feature I didn’t expect to care about as much as I did: the Temporal Web UI. Having a first-class UI to see workflow state and history felt like a big quality-of-life upgrade. In healthcare, that same traceability is also what you want for HIPAA-style audit questions: what happened, when, and why.

There’s real friction with orchestration. In an on‑prem setup you’re running more moving parts: the Temporal server, the Web UI, and your workers. That’s more deployment and more things to keep healthy. The programming model is also different. Determinism isn’t a detail. If your codebase wasn’t written with that separation in mind, adopting orchestration can turn into more refactoring than you expect. I didn’t hit the worst-case here, but it’s a cost I wouldn’t ignore.

If I were doing this with a larger team or in a tighter production setting, I’d strongly consider a managed offering instead of running it myself. Temporal’s team also offers a hosted Cloud service.

For this feature, I traded some decoupling for **better observability, step-level retries, and durability**. For a user-facing EHR workflow, that was the right deal.

## Resources

- Temporal docs: https://docs.temporal.io/
- Temporal Concepts (workflows, activities, determinism): https://docs.temporal.io/concepts
- AWS Serverless Event-Driven Architecture patterns: https://docs.aws.amazon.com/whitepapers/latest/serverless-architectures-lambda/serverless-architectures-lambda.pdf
- AWS SQS DLQ docs: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html

---
layout: default
title: "Orchestration vs Choreography: Two Ways to Build Clinical Speech-to-Text"
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
excerpt: "I built clinical transcription twice, once with event-driven choreography on AWS and once with workflow orchestration in Folium. Both are “async,” but they break in different ways. Here’s the tradeoff and why it matters in healthcare."
---

I built clinical transcription twice — once with event-driven choreography on AWS, once with workflow orchestration in [Folium EHR](https://github.com/FoliumAI/folium). I wrote about the first approach in the [Medical Calls Analysis series](https://pedropcamellon.github.io/blog/2024-04-27-medical-calls-analysis-in-aws-part-1-getting-started/2024-04-27-medical-calls-analysis-in-aws-part-1-getting-started.html).

The core insight: **choreography and orchestration are not the same thing.** I used to mentally lump them together as "async" until I built both and felt the tradeoffs up close. The difference matters a lot more when you're handling clinical data.

## Two Patterns for Async Work

Before getting into the specifics, it's worth naming the two patterns clearly.

**Choreography** (event-driven): each service reacts to events independently. No central coordinator. S3 emits an event, Lambda picks it up, writes to S3, another Lambda picks that up. Each service knows its own job and nothing else. The "workflow" is an emergent property of events flowing between services.

**Orchestration** (workflow-driven): a central coordinator defines the steps, owns the state, and controls the sequence. Each step is an explicit function call. The workflow is the code — one file, readable, testable, versionable.

Both are valid. They optimize for different things.

## The Choreography Approach

The AWS pattern for clinical transcription is well-established. S3 event → Lambda → Transcribe → S3 → Lambda → Bedrock → S3. Fully managed. Scales to zero. Costs almost nothing at low volume. I built a version of this in the [Medical Calls Analysis series](https://pedropcamellon.github.io/blog/2024-04-27-medical-calls-analysis-in-aws-part-1-getting-started/2024-04-27-medical-calls-analysis-in-aws-part-1-getting-started.html).

Choreography is a solid default for a lot of systems.

But think about what happens when a Lambda times out mid-pipeline. The message hits the DLQ. No alarm fires. Nobody notices for hours. A clinician's notes from that morning are just... gone. No error surface, no visible status, no obvious place to even start looking.

To debug it, you correlate CloudWatch logs across three Lambda functions, check the SQS DLQ, inspect S3 prefixes, and piece together what happened from timestamps.

That's the fundamental tradeoff of choreography: **there's no centralized state.** Each service knows its own slice. Nobody knows the full picture of a single job. To answer "where is this transcription right now?" you have to ask five different systems and hope the correlation IDs line up.

Choreography gives you decoupling and independence. It takes away visibility and coordinated failure handling.

## The Tradeoffs

I don’t think orchestration is “better” in a vacuum. It comes with real costs and tradeoffs, and in a lot of systems choreography is the right call.

### Where choreography tends to win

- **Infrastructure:** Fully managed primitives (S3, Lambda, SQS)
- **Cost at low volume:** Nearly free (pay-per-invoke)
- **Getting started:** Wire an event and ship it
- **Coupling:** Services are decoupled by default
- **Failure blast radius:** Distributed. One function timing out does not pause the whole system

### Where orchestration tends to win

- **Failure visibility:** Built-in workflow history and status
- **Retry control:** Per-step retries with backoff and error classes
- **Debugging:** You can inspect one workflow run instead of correlating logs across services
- **State:** Centralized state for a single job ("where is this transcription right now?")

One tradeoff that’s easy to underestimate: with orchestration, the coordinator is load-bearing infrastructure. If it goes down, workflows pause until it comes back. With choreography, failures are more distributed by design.

Orchestration engines also enforce constraints that can trip you up at first. In Temporal, workflow code must be deterministic (no random numbers, no direct I/O, no `datetime.now()`). Side effects go in activities, coordination goes in workflows.

A small but important implication: if the workflow fails during step 2, the engine retries step 2. Steps 1 and 3 do not re-run. That is deterministic replay in practice.

This annoyed me at first. Then I realized it forces a clean separation I'd want anyway: **coordination logic vs. real work.** It's just good architecture with the engine enforcing it.

But if your team has never worked with orchestration engines, budget real ramp-up time. The mental model is genuinely different from event-driven.

## Why Healthcare Tips the Scale Toward Orchestration

In most domains, choreography's tradeoffs are acceptable. A lost analytics event or a delayed notification isn't catastrophic.

Healthcare is different.

A lost transcription is a lost patient encounter. A Lambda timeout mid-pipeline can mean the message hits the DLQ, no alarm fires, and nobody finds out until a clinician reports missing notes. That's not a bug report. That's a compliance incident.

Orchestration gives you an audit trail by default. Every event logged, every state transition queryable. HIPAA wants to know where PHI flows and who touched it? It's in the workflow history. In a choreographed setup, building an equivalent audit trail is a separate project — one that's easy to deprioritize until you need it.

The "async trap" is real: choreography gives you non-blocking execution but not durability. A crashed function can lose its in-flight job. A crashed orchestration worker is just a pause. The workflow picks up on the next available worker.

In healthcare, durability isn't a nice-to-have. It's the whole point.

## What I'd Do Differently

Polling for transcription status is the current approach in Folium. WebSocket push would cut latency and reduce server load. That's the natural next step.

I'd also formalize workflow IDs around patient encounter IDs from day one. Orchestration workflows are naturally idempotent when keyed to a business ID. Start the same workflow ID twice and the engine just returns the existing run.

## The Bottom Line

For multi-step AI workflows where failures matter, I’ve found orchestration to be the better fit. The visibility and durability are hard to replicate in a choreographed system, and in healthcare those properties matter a lot.

For a simple event trigger (thumbnail resize, log processor, webhook relay), choreography is usually simpler, cheaper, and perfectly fine when losing one event isn’t the end of the world.

The mistake is treating these as the same category. "Async" is not one thing. Choreography and orchestration solve different problems. I learned that by building the same system twice.

## Resources

- Temporal docs: https://docs.temporal.io/
- Temporal Concepts (workflows, activities, determinism): https://docs.temporal.io/concepts
- AWS Serverless Event-Driven Architecture patterns: https://docs.aws.amazon.com/whitepapers/latest/serverless-architectures-lambda/serverless-architectures-lambda.pdf
- AWS SQS DLQ docs: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html

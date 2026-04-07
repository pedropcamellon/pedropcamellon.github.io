---
layout: default
title: "Evaluating Workflow Orchestration Frameworks"
date: 2025-12-23
tags: ["python", "azure", "temporal", "orchestration", "distributed-systems"]
---

I recently built hands-on POCs comparing Azure Durable Functions, Temporal, Prefect, and Dapr for orchestrating event-driven AI pipelines.

## Key Learnings

- **Deterministic replay** is critical for fault recovery in production systems
- **Multi-service architecture patterns** vary significantly across frameworks
- **Local dev experience** directly impacts iteration speed and debugging

## The Approach

Implemented the same invoice processing workflow (PDF → parse → fan-out/fan-in → aggregate) across all three frameworks for an apples-to-apples comparison.

## Trade-offs

Each framework trades off different things—replay mechanisms, vendor lock-in, operational complexity, and developer experience all factor into the decision.

**Full comparison on Notion:** [Read the detailed analysis](https://pedropcamellon.notion.site/Orchestration-Frameworks-Comparison-2d054742cee980a2a581eaf213704505)

**GitHub repo:** [View the code](https://github.com/pedropcamellon/workflow-orchestration-poc)

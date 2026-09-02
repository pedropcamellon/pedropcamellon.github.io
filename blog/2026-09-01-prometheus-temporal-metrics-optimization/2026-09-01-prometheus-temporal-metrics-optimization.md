---
layout: default
title: "Prometheus Beyond Defaults: Cutting Temporal Metric Ingestion by 93.9%"
date: 2026-09-01
excerpt: "After adding Temporal to Folium, a one-minute allowlist reduced Prometheus's retained Temporal samples from 7,112 to 435 per scrape."
is_new: true
tags: ["prometheus", "temporal", "observability", "docker", "metrics"]
---

## The next task after adding Temporal

Adding Temporal gave Folium durable workflow execution, but it also introduced a
large metrics endpoint. Prometheus was scraping every Temporal metric every 15
seconds by default. That is reasonable during exploration; it is not a storage
policy.

My next task was to keep the metrics that answer operational questions and stop
storing the rest. The goal was lower Prometheus TSDB growth now, and less
ingestion volume if this stack later sends metrics through remote write.

## Start with what the service actually emits

I measured the live endpoint before adding filters. It exposed 195 metric
families and produced 7,112 samples in one scrape. The raw response was about
1.19 MB. The largest families were histogram buckets such as
`poll_latency_bucket` and `persistence_latency_bucket`, where each label and
bucket combination becomes another series receiving a sample every scrape.

To find the families doing the work, I ran this against the raw endpoint. It
counts how often each metric name appears in one scrape:

```bash
curl -fsS http://localhost:9464/metrics \
  | grep -E '^[a-zA-Z_:][a-zA-Z0-9_:]*' \
  | sed -E 's/\{.*//; s/[[:space:]].*//' \
  | sort | uniq -c | sort -nr | head -30
```

The pipeline is intentionally simple: `curl` fetches the exposition text,
`grep` keeps sample rows, `sed` strips labels and values, `uniq -c` counts names,
and the final sort returns the 30 largest families. The captured baseline began
like this:

```text
1340 poll_latency_bucket
1140 persistence_latency_bucket
420 service_latency_nouserlatency_bucket
420 service_latency_bucket
320 client_latency_bucket
260 temporal_request_latency_bucket
260 temporal_request_latency_attempt_bucket
```

That made the decision concrete. The largest families were histogram buckets
that no Folium dashboard used, so I could apply a narrow allowlist instead of a
broad guesswork-driven filter.

The dashboard review mattered just as much as the inventory. The original
workflow-outcome query named metrics that the local Temporal endpoint did not
emit. Keeping a metric for an invalid query would have been storage cost without
operational value.

## Store the questions, not the endpoint

I changed only the Temporal job. It now scrapes once per minute with a
1,000-sample safety cap. A metric allowlist retains workflow completion, request
errors and counts, queue backlog and lag, worker capacity, retries, and request
latency totals and counts.

```yaml
- job_name: "temporal"
  scrape_interval: 1m
  sample_limit: 1000
  metric_relabel_configs:
    - source_labels: [__name__]
      regex: "(workflow_success|service_errors|service_requests|...)"
      action: keep
    - action: labeldrop
      regex: "(worker_build_id|partition|namespace_id|workflow_id|run_id)"
```

I kept `service_name`, `namespace`, and `taskqueue` because they help route an
incident. I dropped workflow/run IDs, partitions, and worker build IDs because
they are unbounded or deployment-specific dimensions.

## The result: 7,112 to 435 samples

After the policy loaded, Prometheus fetched 7,112 Temporal samples but retained
435 after metric relabeling. That is a $93.9\%$ reduction per scrape:

$$
1 - \frac{435}{7112} \approx 93.9\%
$$

The post-reload measurement window contained 288 Temporal series. Changing the
scrape interval from 15 seconds to one minute reduced the write cadence by a
further factor of four. The effective sample-write volume moved from about
$28{,}448$ samples per minute before filtering to about $435$ retained samples
per minute after the policy, a reduction of roughly $98.5\%$ for this job.

I then asked Prometheus to report both sides of the decision: what it fetched
and what it accepted for storage.

```bash
# Samples fetched from Temporal before filtering.
curl -fsSG http://localhost:9090/api/v1/query \
  --data-urlencode 'query=scrape_samples_scraped{job="temporal"}'

# Samples retained for Prometheus storage after filtering.
curl -fsSG http://localhost:9090/api/v1/query \
  --data-urlencode 'query=scrape_samples_post_metric_relabeling{job="temporal"}'
```

The first query reads Prometheus's scrape counter before relabeling; the second
reads the count left after `metric_relabel_configs`. The captured results were:

```json
{
  "metric": {
    "__name__": "scrape_samples_scraped",
    "instance": "folium-temporal:8000",
    "job": "temporal"
  },
  "value": [1788306162.168, "7112"]
}
```

```json
{
  "metric": {
    "__name__": "scrape_samples_post_metric_relabeling",
    "instance": "folium-temporal:8000",
    "job": "temporal"
  },
  "value": [1788312514.087, "435"]
}
```

The `7,112` fetched samples are numeric values from one scrape, not 7,112 new
tables or necessarily 7,112 new series. The `435` samples are what Prometheus
accepted after the allowlist and label-drop rules. That is the proof of the
storage decision: 6,677 samples were dropped, leaving $6.1\%$ retained and
$93.9\%$ removed.

## Storage first, with one boundary

The savings are mainly in Prometheus storage: fewer samples written to TSDB,
fewer active series, less query surface, and less downstream remote-write
volume. `metric_relabel_configs` runs after Prometheus downloads `/metrics`, so
it does not make Temporal's raw endpoint response smaller. Reducing endpoint
network payload would require changing Temporal's metric emission or filtering
closer to the exporter.

## Prove the retained metrics are still useful

I replaced the dashboard's invalid workflow-outcome expressions with signals
that were actually emitted and retained. `workflow_success` measures completed
workflows; the local endpoint did not emit `workflow_failed`, so
`service_errors` is the failure-investigation signal.

```promql
rate(workflow_success{job="temporal"}[5m])
rate(service_errors{job="temporal"}[5m])
```

I also checked that the target was healthy and running on the intended interval:

```bash
curl -fsS http://localhost:9090/api/v1/targets \
  | jq -r '.data.activeTargets[]
      | select(.labels.job == "temporal")
      | {health, scrapeInterval, lastScrape, lastError}'
```

The target reported `up` with a one-minute interval, and the retained metrics
still covered completion, request errors, backlog, queue lag, and worker
capacity.

## Why metric cleanup belongs in the rollout

This was important because monitoring defaults quietly become operating costs.
Without a policy, every new Temporal metric, histogram bucket, and label
combination is written repeatedly to local storage and eventually becomes
remote-write volume. The cleanup reduced retained samples by $93.9\%$ per
scrape, from 7,112 to 435, and the one-minute interval reduced the effective
Temporal sample-write rate by about $98.5\%$, from roughly 28,448 to 435 samples
per minute.

After introducing a new workflow service, metric cleanup is a natural next
step, not a later cost exercise. I would start with the dashboard and incident
questions, measure emitted samples and stored samples separately, then write a
small allowlist. I would revisit it when the dashboards change, Temporal is
upgraded, or remote write becomes part of the deployment.

**GitHub Repository:** [Folium](https://github.com/pedropcamellon/folium)

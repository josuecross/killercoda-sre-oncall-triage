#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-sre-triage}"

mkdir -p "$LAB_DIR"

cat > "$LAB_DIR/alert.txt" <<'EOF'
TaskFlow Demo synthetic alert

Alert name: APIHigh5xxErrorRate
Service: api-service
Primary workflow: task-create
Condition: API 5xx error rate above threshold for 12 minutes
Observed error rate: 7.8%
Alert threshold: 5.0% for 10 minutes
Secondary signal: p95 latency mildly elevated
Initial severity hint: SEV-3 / Medium unless broader impact evidence appears

Clean-room note: This is fictional educational evidence, not a real alert.
EOF

cat > "$LAB_DIR/metrics_snapshot.txt" <<'EOF'
TaskFlow Demo synthetic metrics snapshot
Window: last 15 minutes

api-service request summary:
- Total request volume: steady to mildly elevated
- Overall 5xx error rate: 7.8%
- task-create 5xx error rate: 18.6%
- task-list 5xx error rate: 0.7%
- task-detail 5xx error rate: 0.9%
- p95 latency overall: 480 ms
- p95 latency for task-create: 920 ms
- p95 latency for read-only task views: 260 ms

Interpretation hints:
- Error rate is the primary signal.
- Latency is mildly elevated, especially for task-create, but it is not the main alert condition.
- The service appears degraded, not fully unavailable.
- Read-only task views mostly continue working.
- Additional evidence is needed before naming a root cause.
EOF

cat > "$LAB_DIR/api_logs_excerpt.txt" <<'EOF'
TaskFlow Demo synthetic api-service log excerpt

[lab-time 10:04:12] service=api-service route=POST /tasks workflow=task-create status=201 latency_ms=344 result=success
[lab-time 10:04:39] service=api-service route=GET /tasks workflow=task-list status=200 latency_ms=212 result=success
[lab-time 10:05:18] service=api-service route=POST /tasks workflow=task-create status=500 latency_ms=887 result=server_error
[lab-time 10:06:03] service=api-service route=POST /tasks workflow=task-create status=500 latency_ms=941 result=server_error
[lab-time 10:06:44] service=api-service route=GET /tasks/summary workflow=task-summary status=200 latency_ms=248 result=success
[lab-time 10:07:10] service=api-service route=POST /tasks workflow=task-create status=201 latency_ms=391 result=success
[lab-time 10:08:27] service=api-service route=POST /tasks workflow=task-create status=500 latency_ms=978 result=server_error
[lab-time 10:09:02] service=api-service route=GET /tasks workflow=task-list status=200 latency_ms=229 result=success
[lab-time 10:10:33] service=api-service route=POST /tasks workflow=task-create status=500 latency_ms=1004 result=server_error
[lab-time 10:11:21] service=api-service route=GET /tasks/12345 workflow=task-detail status=200 latency_ms=241 result=success

Responder note:
- These entries show a pattern, not a final cause.
- Do not declare root cause from this excerpt alone.
- Consider dependency degradation, misconfiguration, partial deployment issue, traffic spike, database timeout, or bad validation path.
EOF

cat > "$LAB_DIR/service_status.txt" <<'EOF'
TaskFlow Demo synthetic service status

api-service: degraded
task-create workflow: intermittent failures
read-only task views: mostly healthy
authentication: no known issue in this teaser
task notifications: not evaluated in this teaser
overall customer impact: some users may see intermittent task creation failures

Current responder framing:
- The service is not completely down.
- The issue appears concentrated around task-create.
- Initial severity hypothesis: SEV-3 / Medium unless broader impact evidence appears.
EOF

cat > "$LAB_DIR/runbook_excerpt.md" <<'EOF'
# Synthetic Runbook Excerpt: API Error Rate Triage

## First Response Goals

1. Confirm what alert fired.
2. Identify the affected service and workflow.
3. Separate primary signal from supporting signals.
4. Estimate customer impact.
5. Assign an initial severity.
6. Draft a short stakeholder update.
7. Pick the next investigation step.

## Severity Guide

- SEV-1 / Critical: Widespread outage, severe user impact, or urgent data integrity risk.
- SEV-2 / High: Major workflow unavailable for many users or impact expanding quickly.
- SEV-3 / Medium: Degraded service or intermittent failure affecting a subset of users.
- SEV-4 / Low: Minor issue, low impact, workaround available, or investigation-only event.

## Initial Hypothesis For This Teaser

Start at SEV-3 / Medium if the evidence remains limited to intermittent task-create failures and read-only task views mostly continue working.

Escalate if evidence shows the issue affects most requests, critical workflows are fully unavailable, the impact is spreading, or there is a data integrity concern.

## Possible Issue Categories

Use these as investigation categories only:

- Dependency degradation
- Misconfiguration
- Partial deployment issue
- Traffic spike
- Database timeout
- Bad validation path

Do not choose a final root cause without more evidence.
EOF

cat > "$LAB_DIR/incident_notes.md" <<'EOF'
# Incident Notes Template

## Status

Write one sentence describing the current state.

## Impact

Who or what appears affected?

## Current Evidence

What alert, metrics, logs, or service-status details support your current view?

## Initial Severity

SEV level:
Reasoning:

## Next Action

What will you check next?

## Next Update Time

When should stakeholders expect the next update?

## Unknowns

What should not be assumed yet?
EOF

echo "Synthetic TaskFlow Demo SRE triage evidence created in $LAB_DIR"

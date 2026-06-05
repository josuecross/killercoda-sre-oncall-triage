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

HELPER_BIN_DIR="${HELPER_BIN_DIR:-/usr/local/bin}"

if ! mkdir -p "$HELPER_BIN_DIR" 2>/dev/null || [ ! -w "$HELPER_BIN_DIR" ]; then
  HELPER_BIN_DIR=""
  OLD_IFS="$IFS"
  IFS=":"
  for path_dir in $PATH; do
    if [ -d "$path_dir" ] && [ -w "$path_dir" ]; then
      HELPER_BIN_DIR="$path_dir"
      break
    fi
  done
  IFS="$OLD_IFS"
fi

if [ -z "$HELPER_BIN_DIR" ]; then
  HELPER_BIN_DIR="$LAB_DIR/bin"
  mkdir -p "$HELPER_BIN_DIR"
fi

cat > "$HELPER_BIN_DIR/taskflowctl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-sre-triage}"

show_file() {
  local file="$1"
  local path="$LAB_DIR/$file"

  if [ ! -f "$path" ]; then
    echo "Missing synthetic evidence file: $path"
    echo "If this is Killercoda, wait a few seconds for setup to finish, then retry."
    exit 1
  fi

  cat "$path"
}

case "${1:-help}" in
  help)
    cat <<'HELP'
taskflowctl: synthetic TaskFlow Demo triage helper

Commands:
  taskflowctl help      Show this help text
  taskflowctl alert     Show the synthetic alert
  taskflowctl status    Show synthetic service status
  taskflowctl metrics   Show synthetic metrics snapshot
  taskflowctl logs      Show synthetic API log excerpt
  taskflowctl runbook   Show synthetic runbook excerpt
  taskflowctl notes     Show incident notes path and editing suggestion
  taskflowctl hints     Show non-spoiler triage hints

This helper is fictional and reads local synthetic evidence only.
HELP
    ;;
  alert)
    show_file "alert.txt"
    ;;
  status)
    show_file "service_status.txt"
    ;;
  metrics)
    show_file "metrics_snapshot.txt"
    ;;
  logs)
    show_file "api_logs_excerpt.txt"
    ;;
  runbook)
    show_file "runbook_excerpt.md"
    ;;
  notes)
    cat <<NOTES
Incident notes file:
  $LAB_DIR/incident_notes.md

Suggested edit command:
  nano $LAB_DIR/incident_notes.md

After writing your notes, run:
  check-triage
NOTES
    ;;
  hints)
    cat <<'HINTS'
Non-spoiler triage hints:
- Identify the primary signal.
- Avoid naming root cause too early.
- Compare task-create vs read-only task views.
- Classify severity from current impact.
- Draft the update with status, impact, evidence, next action, and next update time.
HINTS
    ;;
  *)
    echo "Unknown taskflowctl command: $1"
    echo "Run: taskflowctl help"
    exit 1
    ;;
esac
EOF

chmod +x "$HELPER_BIN_DIR/taskflowctl"

cat > "$HELPER_BIN_DIR/check-triage" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-sre-triage}"
NOTES_FILE="$LAB_DIR/incident_notes.md"

if [ ! -f "$NOTES_FILE" ]; then
  echo "Missing incident notes file: $NOTES_FILE"
  echo "If this is Killercoda, wait a few seconds for setup to finish, then retry."
  exit 0
fi

section_text() {
  local section="$1"
  awk -v section="$section" '
    $0 == "## " section { in_section=1; next }
    in_section && /^## / { exit }
    in_section { print }
  ' "$NOTES_FILE"
}

clean_section_text() {
  awk '
    /^[[:space:]]*$/ { next }
    $0 == "Write one sentence describing the current state." { next }
    $0 == "Who or what appears affected?" { next }
    $0 == "What alert, metrics, logs, or service-status details support your current view?" { next }
    $0 == "SEV level:" { next }
    $0 == "Reasoning:" { next }
    $0 == "What will you check next?" { next }
    $0 == "When should stakeholders expect the next update?" { next }
    $0 == "What should not be assumed yet?" { next }
    { print }
  '
}

section_filled() {
  local section="$1"
  local cleaned
  cleaned="$(section_text "$section" | clean_section_text)"
  [ -n "$cleaned" ]
}

missing_sections=()
filled_count=0

for section in "Status" "Impact" "Current Evidence" "Initial Severity" "Next Action" "Next Update Time" "Unknowns"; do
  if section_filled "$section"; then
    filled_count=$((filled_count + 1))
  else
    missing_sections+=("$section")
  fi
done

term_count=0
grep -Eiq 'SEV-3|Medium' "$NOTES_FILE" && term_count=$((term_count + 1))
grep -Eiq 'api-service' "$NOTES_FILE" && term_count=$((term_count + 1))
grep -Eiq 'task-create' "$NOTES_FILE" && term_count=$((term_count + 1))
grep -Eiq 'error rate' "$NOTES_FILE" && term_count=$((term_count + 1))
grep -Eiq 'unknown|not assume' "$NOTES_FILE" && term_count=$((term_count + 1))

echo "Synthetic triage note check"
echo
echo "Sections with learner content: $filled_count / 7"
echo "Useful reasoning terms found: $term_count / 5"
echo

if [ "${#missing_sections[@]}" -gt 0 ]; then
  echo "Consider adding content under:"
  for section in "${missing_sections[@]}"; do
    echo "- $section"
  done
  echo
fi

if [ "$term_count" -lt 3 ]; then
  cat <<'FEEDBACK'
Consider mentioning more of the evidence you used:
- severity hypothesis, such as SEV-3 / Medium
- affected service, api-service
- affected workflow, task-create
- primary signal, error rate
- what remains unknown or should not be assumed

FEEDBACK
fi

if [ "$filled_count" -ge 6 ] && [ "$term_count" -ge 4 ]; then
  echo "Good first-pass triage note. Compare your reasoning with the paid full labs if you want the deeper answer-key format."
else
  echo "Keep going. A strong first-pass note is short, specific, and clear about what is still unknown."
fi
EOF

chmod +x "$HELPER_BIN_DIR/check-triage"

echo "Synthetic TaskFlow Demo SRE triage evidence created in $LAB_DIR"
echo "Synthetic helper commands installed in $HELPER_BIN_DIR"

#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-sre-triage}"
TASKFLOW_PORT="${TASKFLOW_PORT:-18080}"
APP_DIR="$LAB_DIR/app"

mkdir -p "$APP_DIR"
rm -f "$LAB_DIR/metrics_snapshot.txt" "$LAB_DIR/api_logs_excerpt.txt"

cat > "$LAB_DIR/alert.txt" <<'EOF'
TaskFlow Demo synthetic alert

Alert name: APIHigh5xxErrorRate
Service: api-service
Primary workflow: task-create
Condition: API 5xx error rate above threshold for 12 minutes
Severity hint: SEV-3 / Medium unless broader impact appears

Clean-room note: This is fictional educational evidence, not a real alert.
EOF

cat > "$LAB_DIR/service_status.txt" <<'EOF'
TaskFlow Demo synthetic service status

api-service: degraded
task-create workflow: intermittent failures
read-only task views: mostly healthy
service availability: not fully down
initial severity hypothesis: SEV-3 / Medium

Responder framing:
- Some users may see intermittent failures when creating tasks.
- Read-only task views mostly continue working.
- Do not name a final root cause from this status summary alone.
EOF

cat > "$LAB_DIR/runbook_excerpt.md" <<'EOF'
# Synthetic Runbook Excerpt: API Error Rate Triage

## First Response Goals

1. Confirm the alert details.
2. Check whether the service is reachable.
3. Reproduce task-create failures.
4. Compare `GET /tasks` with `POST /tasks`.
5. Inspect container logs for error patterns.
6. Estimate the observed error rate.
7. Draft a short stakeholder update.
8. Avoid naming root cause too early.

## Severity Guide

- SEV-1 / Critical: Widespread outage, severe user impact, or urgent data integrity risk.
- SEV-2 / High: Major workflow unavailable for many users or impact expanding quickly.
- SEV-3 / Medium: Degraded service or intermittent failure affecting a subset of users.
- SEV-4 / Low: Minor issue, low impact, workaround available, or investigation-only event.

## Escalation Prompts

Escalate if evidence shows most requests are failing, the impact spreads beyond task-create, read-only views become unavailable, or there is a data integrity concern.

## Investigation Caution

Use logs and metrics as evidence, not proof of final root cause. This teaser is about first-response triage, not solving the full incident.
EOF

cat > "$LAB_DIR/incident_notes.md" <<'EOF'
# Incident Notes Template

## Status

Write one sentence describing the current state.

## Impact

Who or what appears affected?

## Current Evidence

What alert, curl, metrics, logs, or service-status details support your current view?

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

cat > "$APP_DIR/taskflow_api.py" <<'EOF'
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import time

HOST = "0.0.0.0"
PORT = 8080

state = {
    "total_requests": 0,
    "task_create_requests": 0,
    "task_create_errors": 0,
}


def lab_time():
    minute = 5 + (state["total_requests"] // 60)
    second = state["total_requests"] % 60
    return f"10:{minute:02d}:{second:02d}"


def emit_log(method, path, workflow, status, latency_ms, result):
    print(
        " ".join(
            [
                f"lab_time={lab_time()}",
                "service=api-service",
                f"method={method}",
                f"path={path}",
                f"workflow={workflow}",
                f"status={status}",
                f"latency_ms={latency_ms}",
                f"result={result}",
            ]
        ),
        flush=True,
    )


class TaskFlowHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        return

    def write_text(self, status, body):
        self.send_response(status)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(body.encode("utf-8"))

    def do_GET(self):
        state["total_requests"] += 1

        if self.path == "/healthz":
            emit_log("GET", "/healthz", "health-check", 200, 35, "success")
            self.write_text(200, "ok\n")
            return

        if self.path == "/tasks":
            emit_log("GET", "/tasks", "task-list", 200, 210, "success")
            self.write_text(200, "synthetic task list\n")
            return

        if self.path == "/metrics":
            task_requests = state["task_create_requests"]
            task_errors = state["task_create_errors"]
            error_rate = (task_errors / task_requests * 100) if task_requests else 0.0
            body = "\n".join(
                [
                    "TaskFlow Demo synthetic metrics",
                    f"total_requests: {state['total_requests']}",
                    f"task_create_requests: {task_requests}",
                    f"task_create_errors: {task_errors}",
                    f"approx_task_create_error_rate_percent: {error_rate:.2f}",
                    "",
                ]
            )
            emit_log("GET", "/metrics", "metrics", 200, 52, "success")
            self.write_text(200, body)
            return

        emit_log("GET", self.path, "unknown", 404, 25, "not_found")
        self.write_text(404, "synthetic route not found\n")

    def do_POST(self):
        state["total_requests"] += 1

        if self.path != "/tasks":
            emit_log("POST", self.path, "unknown", 404, 28, "not_found")
            self.write_text(404, "synthetic route not found\n")
            return

        state["task_create_requests"] += 1
        should_fail = state["task_create_requests"] % 3 == 0

        if should_fail:
            state["task_create_errors"] += 1
            emit_log("POST", "/tasks", "task-create", 500, 912, "server_error")
            self.write_text(500, "synthetic task-create failure\n")
            return

        emit_log("POST", "/tasks", "task-create", 201, 384, "success")
        self.write_text(201, "synthetic task created\n")


if __name__ == "__main__":
    print(
        f"Synthetic TaskFlow Demo api-service listening on {HOST}:{PORT}",
        flush=True,
    )
    HTTPServer((HOST, PORT), TaskFlowHandler).serve_forever()
EOF

docker rm -f taskflow-api >/dev/null 2>&1 || true
docker run -d \
  --name taskflow-api \
  -p "${TASKFLOW_PORT}:8080" \
  -v "$APP_DIR:/app:ro" \
  python:3.12-alpine \
  python /app/taskflow_api.py >/dev/null

for i in $(seq 1 20); do
  if curl -fsS "http://localhost:${TASKFLOW_PORT}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

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

rm -f "$HELPER_BIN_DIR/taskflowctl"

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
    $0 == "What alert, curl, metrics, logs, or service-status details support your current view?" { next }
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
  echo "Good first-pass triage note. You captured the key shape of an SRE update."
else
  echo "Keep going. A strong first-pass note is short, specific, and clear about what is still unknown."
fi
EOF

chmod +x "$HELPER_BIN_DIR/check-triage"

echo "Synthetic TaskFlow Demo API is running at http://localhost:${TASKFLOW_PORT}"
echo "Evidence workspace: $LAB_DIR"

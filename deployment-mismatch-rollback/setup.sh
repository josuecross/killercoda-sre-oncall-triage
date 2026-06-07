#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-release-lab}"
TASKFLOW_RELEASE_PORT="${TASKFLOW_RELEASE_PORT:-18082}"
APP_DIR="$LAB_DIR/app"

mkdir -p "$APP_DIR"

cat > "$APP_DIR/taskflow_release_api.py" <<'PYEOF'
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import threading

HOST = "0.0.0.0"
PORT = 8080

state = {
    "api_version": "2026.05-training.2",
    "expected_ruleset": "ruleset-v2-training",
    "running_ruleset": "ruleset-v1-training",
    "previous_stable_version": "2026.05-training.1",
    "mode": "mismatch",
    "task_create_success_count": 0,
    "task_create_error_count": 0,
    "mitigation_applied": 0,
    "request_count": 0,
}

lock = threading.Lock()


def lab_time():
    minute = 20 + (state["request_count"] // 30)
    second = (state["request_count"] * 4) % 60
    return f"10:{minute:02d}:{second:02d}"


def is_compatible():
    return state["expected_ruleset"] == state["running_ruleset"]


def mismatch_value():
    return 0 if is_compatible() else 1


def log_event(result, extra=""):
    suffix = f" {extra}" if extra else ""
    print(
        "lab_time={time} service=api-service component=release-check "
        "api_version={api_version} expected_ruleset={expected_ruleset} "
        "running_ruleset={running_ruleset} mode={mode} result={result}{suffix}".format(
            time=lab_time(),
            api_version=state["api_version"],
            expected_ruleset=state["expected_ruleset"],
            running_ruleset=state["running_ruleset"],
            mode=state["mode"],
            result=result,
            suffix=suffix,
        ),
        flush=True,
    )


class Handler(BaseHTTPRequestHandler):
    def _send(self, status, body, content_type="text/plain"):
        encoded = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def _tick(self):
        state["request_count"] += 1

    def do_GET(self):
        with lock:
            self._tick()

            if self.path == "/healthz":
                self._send(200, "ok\n")
                return

            if self.path == "/status":
                log_event("status_checked")
                body = "\n".join(
                    [
                        "TaskFlow Demo synthetic release status",
                        "",
                        "api-service: reachable",
                        "health check: passing",
                        "task-create workflow: degraded",
                        "release/config mismatch: suspected",
                        "initial severity: SEV-3 / Medium unless broader impact appears",
                        "",
                        "Responder framing:",
                        "- Health passing does not prove every workflow is healthy.",
                        "- Compare release, version, config, logs, and workflow behavior.",
                        "- Do not claim a completed explanation from status alone.",
                        "",
                    ]
                )
                self._send(200, body)
                return

            if self.path == "/version":
                log_event("version_checked")
                body = "\n".join(
                    [
                        "TaskFlow Demo synthetic version",
                        f"api_version: {state['api_version']}",
                        f"previous_stable_version: {state['previous_stable_version']}",
                        "",
                    ]
                )
                self._send(200, body)
                return

            if self.path == "/release":
                log_event("release_checked")
                body = "\n".join(
                    [
                        "TaskFlow Demo synthetic intended release",
                        f"intended_api_version: {state['api_version']}",
                        f"expected_ruleset: {state['expected_ruleset']}",
                        "",
                    ]
                )
                self._send(200, body)
                return

            if self.path == "/config":
                result = "config_compatible" if is_compatible() else "mismatch_detected"
                log_event(result)
                body = "\n".join(
                    [
                        "TaskFlow Demo synthetic runtime config",
                        f"running_ruleset: {state['running_ruleset']}",
                        f"expected_ruleset: {state['expected_ruleset']}",
                        f"compatibility_status: {'compatible' if is_compatible() else 'mismatch'}",
                        "",
                    ]
                )
                self._send(200, body)
                return

            if self.path == "/tasks":
                log_event("read_path_success", "workflow=task-list status=200")
                self._send(200, "synthetic task list\n")
                return

            if self.path == "/metrics":
                body = "\n".join(
                    [
                        "# TaskFlow Demo synthetic release metrics",
                        f"taskflow_task_create_errors {state['task_create_error_count']}",
                        f"taskflow_task_create_successes {state['task_create_success_count']}",
                        f"taskflow_release_mismatch {mismatch_value()}",
                        f"taskflow_mitigation_applied {state['mitigation_applied']}",
                        "",
                    ]
                )
                self._send(200, body)
                return

        self._send(404, "not found\n")

    def do_POST(self):
        with lock:
            self._tick()

            if self.path == "/tasks":
                if not is_compatible():
                    state["task_create_error_count"] += 1
                    log_event(
                        "task_create_failed",
                        "workflow=task-create status=500 reason=release_config_mismatch",
                    )
                    self._send(500, "task-create failed: release/config mismatch\n")
                    return

                state["task_create_success_count"] += 1
                log_event("task_create_success", "workflow=task-create status=201")
                self._send(201, "synthetic task created\n")
                return

            if self.path == "/mitigate/rollback":
                state["api_version"] = "2026.05-training.1"
                state["expected_ruleset"] = "ruleset-v1-training"
                state["running_ruleset"] = "ruleset-v1-training"
                state["mode"] = "rolled_back"
                state["mitigation_applied"] = 1
                log_event("rollback_applied")
                self._send(
                    200,
                    "Synthetic rollback applied: API and ruleset returned to compatible training release\n",
                )
                return

            if self.path == "/mitigate/align-config":
                state["api_version"] = "2026.05-training.2"
                state["expected_ruleset"] = "ruleset-v2-training"
                state["running_ruleset"] = "ruleset-v2-training"
                state["mode"] = "config_aligned"
                state["mitigation_applied"] = 1
                log_event("config_alignment_applied")
                self._send(
                    200,
                    "Synthetic fix-forward applied: runtime ruleset aligned with current training release\n",
                )
                return

        self._send(404, "not found\n")

    def log_message(self, format, *args):
        return


print(
    "lab_time=10:20:00 service=api-service component=release-check "
    "api_version=2026.05-training.2 expected_ruleset=ruleset-v2-training "
    "running_ruleset=ruleset-v1-training mode=mismatch result=service_started",
    flush=True,
)
print(
    "lab_time=10:20:00 service=api-service component=release-check "
    "api_version=2026.05-training.2 expected_ruleset=ruleset-v2-training "
    "running_ruleset=ruleset-v1-training mode=mismatch result=mismatch_detected",
    flush=True,
)
ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
PYEOF

cat > "$LAB_DIR/incident_notes.md" <<'EOF'
# Incident Notes Template

## Status

Write one sentence describing the current state.

## Impact

Who or what appears affected?

## Current Evidence

What health, workflow, release, config, metrics, or logs support your current view?

## Initial Severity

SEV level:
Reasoning:

## Mitigation

What mitigation did you apply?

## Verification

How did you verify recovery?

## Next Update Time

When should stakeholders expect the next update?

## Unknowns

What should not be assumed yet?
EOF

HELPER_DIR="${TASKFLOW_HELPER_DIR:-/usr/local/bin}"
if [ ! -w "$HELPER_DIR" ]; then
  for candidate in /opt/homebrew/bin "$LAB_DIR/bin"; do
    if mkdir -p "$candidate" >/dev/null 2>&1 && [ -w "$candidate" ]; then
      HELPER_DIR="$candidate"
      break
    fi
  done
fi

cat > "$HELPER_DIR/check-release-notes" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-release-lab}"
NOTES="$LAB_DIR/incident_notes.md"

if [ ! -f "$NOTES" ]; then
  echo "Notes file not found: $NOTES"
  exit 1
fi

score=0

cleaned_content="$(
  awk '
    function is_placeholder(line) {
      return line == "Write one sentence describing the current state." ||
        line == "Who or what appears affected?" ||
        line == "What health, workflow, release, config, metrics, or logs support your current view?" ||
        line == "SEV level:" ||
        line == "Reasoning:" ||
        line == "What mitigation did you apply?" ||
        line == "How did you verify recovery?" ||
        line == "When should stakeholders expect the next update?" ||
        line == "What should not be assumed yet?"
    }

    /^## Status$/ ||
    /^## Impact$/ ||
    /^## Current Evidence$/ ||
    /^## Initial Severity$/ ||
    /^## Mitigation$/ ||
    /^## Verification$/ ||
    /^## Next Update Time$/ ||
    /^## Unknowns$/ {
      in_section = 1
      next
    }

    /^## / {
      in_section = 0
      next
    }

    /^# / {
      next
    }

    in_section {
      sub(/\r$/, "", $0)
      if ($0 == "") next
      if (is_placeholder($0)) next
      print
    }
  ' "$NOTES"
)"

check_term() {
  local label="$1"
  local pattern="$2"
  if grep -Eiq "$pattern" <<< "$cleaned_content"; then
    echo "OK: mentions $label"
    score=$((score + 1))
  else
    echo "Check: add a note about $label"
  fi
}

check_term "api-service" "api-service"
check_term "deployment/release" "deployment|release"
check_term "mismatch/config" "mismatch|config|ruleset"
check_term "task-create" "task-create"
check_term "rollback/fix-forward/alignment" "rollback|fix-forward|align|alignment"
check_term "verification/recovery" "verified|verification|recovery|recover|successful|succeeds"

echo
if [ -z "$cleaned_content" ]; then
  echo "No learner-written content found yet. Fill in the notes template, then run this checker again."
  exit 0
fi

if [ "$score" -ge 5 ]; then
  echo "Good first-pass release incident note. You captured the service, mismatch signal, mitigation, and recovery evidence."
else
  echo "Keep tightening the note: include service, release/config evidence, affected workflow, mitigation, verification, and unknowns."
fi
EOF

chmod +x "$HELPER_DIR/check-release-notes"

docker rm -f taskflow-release >/dev/null 2>&1 || true
docker run -d \
  --name taskflow-release \
  -p "${TASKFLOW_RELEASE_PORT}:8080" \
  -v "$APP_DIR:/app:ro" \
  python:3.12-alpine \
  python /app/taskflow_release_api.py >/dev/null

for _ in $(seq 1 30); do
  if curl -fsS "http://localhost:${TASKFLOW_RELEASE_PORT}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

curl -fsS "http://localhost:${TASKFLOW_RELEASE_PORT}/healthz" >/dev/null

echo "Synthetic TaskFlow Demo release lab is running at http://localhost:${TASKFLOW_RELEASE_PORT}"
echo "Evidence workspace: $LAB_DIR"

#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-queue-lab}"
TASKFLOW_QUEUE_PORT="${TASKFLOW_QUEUE_PORT:-18081}"
APP_DIR="$LAB_DIR/app"

mkdir -p "$APP_DIR"

cat > "$APP_DIR/taskflow_queue_api.py" <<'PYEOF'
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import threading
import time

HOST = "0.0.0.0"
PORT = 8080

state = {
    "queue_depth": 25,
    "enqueued_total": 120,
    "processed_total": 95,
    "worker_capacity": 1,
    "oldest_message_age_seconds": 150,
    "mode": "degraded",
    "tick": 0,
}

lock = threading.Lock()


def lab_time():
    minute = 10 + (state["tick"] // 30)
    second = (state["tick"] * 2) % 60
    return f"10:{minute:02d}:{second:02d}"


def log_event(result, extra=""):
    suffix = f" {extra}" if extra else ""
    print(
        "lab_time={time} component=notification-worker queue_depth={depth} "
        "oldest_age_seconds={age} worker_capacity={capacity} mode={mode} "
        "result={result}{suffix}".format(
            time=lab_time(),
            depth=state["queue_depth"],
            age=state["oldest_message_age_seconds"],
            capacity=state["worker_capacity"],
            mode=state["mode"],
            result=result,
            suffix=suffix,
        ),
        flush=True,
    )


def advance_queue():
    while True:
        time.sleep(2)
        with lock:
            previous_depth = state["queue_depth"]
            state["tick"] += 1
            incoming = 4 if state["mode"] == "degraded" else 2
            state["queue_depth"] += incoming
            state["enqueued_total"] += incoming
            processed_now = min(state["queue_depth"], state["worker_capacity"])
            state["queue_depth"] -= processed_now
            state["processed_total"] += processed_now

            if state["queue_depth"] > previous_depth:
                state["oldest_message_age_seconds"] += 15
                result = "backlog_growing"
            elif state["queue_depth"] < previous_depth:
                state["oldest_message_age_seconds"] = max(
                    0, state["oldest_message_age_seconds"] - 20
                )
                result = "backlog_draining"
            else:
                result = "backlog_stable"

            if state["queue_depth"] == 0:
                state["oldest_message_age_seconds"] = 0

            log_event(result)


class Handler(BaseHTTPRequestHandler):
    def _send(self, status, body, content_type="text/plain"):
        encoded = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def do_GET(self):
        if self.path == "/healthz":
            self._send(200, "ok\n")
            return

        if self.path == "/status":
            with lock:
                body = "\n".join(
                    [
                        "TaskFlow Demo synthetic queue status",
                        "",
                        "notification-worker: degraded",
                        "queue backlog: growing" if state["mode"] == "degraded" else "queue backlog: draining",
                        "async notifications: delayed",
                        "API read/write path: not evaluated in this lab",
                        "initial severity: SEV-3 / Medium unless broader impact appears",
                        "",
                        "Responder framing:",
                        "- This points to async processing degradation, not total platform outage.",
                        "- Confirm trend before declaring recovery.",
                        "- Do not name a final root cause from this status summary alone.",
                        "",
                    ]
                )
            self._send(200, body)
            return

        if self.path == "/metrics":
            with lock:
                if state["mode"] == "degraded":
                    backlog_status = "backlog_growing"
                elif state["queue_depth"] > 0:
                    backlog_status = "backlog_draining"
                else:
                    backlog_status = "backlog_cleared"

                body = "\n".join(
                    [
                        "# TaskFlow Demo synthetic queue metrics",
                        f"taskflow_queue_depth {state['queue_depth']}",
                        f"taskflow_jobs_enqueued_total {state['enqueued_total']}",
                        f"taskflow_jobs_processed_total {state['processed_total']}",
                        f"taskflow_worker_capacity {state['worker_capacity']}",
                        f"taskflow_oldest_message_age_seconds {state['oldest_message_age_seconds']}",
                        f"taskflow_backlog_status {backlog_status}",
                        "",
                    ]
                )
            self._send(200, body)
            return

        self._send(404, "not found\n")

    def do_POST(self):
        if self.path == "/simulate/burst":
            with lock:
                state["queue_depth"] += 20
                state["enqueued_total"] += 20
                state["oldest_message_age_seconds"] = max(
                    state["oldest_message_age_seconds"], 180
                )
                log_event("burst_added", "burst_jobs=20")
            self._send(200, "Synthetic burst added to queue\n")
            return

        if self.path == "/mitigate/scale-workers":
            with lock:
                state["worker_capacity"] = 8
                state["mode"] = "mitigating"
                log_event("worker_capacity_increased", "new_capacity=8")
            self._send(200, "Synthetic mitigation applied: worker capacity increased\n")
            return

        self._send(404, "not found\n")

    def log_message(self, format, *args):
        return


threading.Thread(target=advance_queue, daemon=True).start()
print(
    "lab_time=10:10:00 component=notification-worker queue_depth=25 "
    "oldest_age_seconds=150 worker_capacity=1 mode=degraded result=service_started",
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

What service status, metrics, queue depth, oldest age, or logs support your current view?

## Initial Severity

SEV level:
Reasoning:

## Mitigation

What safe mitigation did you apply?

## Verification

How did you confirm the backlog stabilized or started draining?

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

cat > "$HELPER_DIR/check-queue-notes" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-queue-lab}"
NOTES="$LAB_DIR/incident_notes.md"

if [ ! -f "$NOTES" ]; then
  echo "Notes file not found: $NOTES"
  exit 1
fi

score=0

check_term() {
  local label="$1"
  local pattern="$2"
  if grep -Eiq "$pattern" "$NOTES"; then
    echo "OK: mentions $label"
    score=$((score + 1))
  else
    echo "Check: add a note about $label"
  fi
}

check_term "worker" "notification-worker|worker"
check_term "queue/backlog" "queue|backlog"
check_term "delay/lag" "delayed|delay|lag"
check_term "metrics or queue depth" "metrics|queue depth|taskflow_queue_depth"
check_term "mitigation/scale" "mitigation|mitigate|scale|capacity"
check_term "verification/recovery" "verified|verification|recovery|draining|stabilized|stable"

echo
if [ "$score" -ge 5 ]; then
  echo "Good first-pass queue triage note. You captured impact, evidence, mitigation, and recovery signals."
else
  echo "Keep tightening the note: include component, backlog signal, impact, mitigation, verification, and unknowns."
fi
EOF

chmod +x "$HELPER_DIR/check-queue-notes"

docker rm -f taskflow-queue >/dev/null 2>&1 || true
docker run -d \
  --name taskflow-queue \
  -p "${TASKFLOW_QUEUE_PORT}:8080" \
  -v "$APP_DIR:/app:ro" \
  python:3.12-alpine \
  python /app/taskflow_queue_api.py >/dev/null

for _ in $(seq 1 30); do
  if curl -fsS "http://localhost:${TASKFLOW_QUEUE_PORT}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

curl -fsS "http://localhost:${TASKFLOW_QUEUE_PORT}/healthz" >/dev/null

echo "Synthetic TaskFlow Demo queue lab is running at http://localhost:${TASKFLOW_QUEUE_PORT}"
echo "Evidence workspace: $LAB_DIR"

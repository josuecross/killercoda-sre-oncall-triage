#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-crashloopbackoff-lab}"
MANIFEST_DIR="$LAB_DIR/manifests"
NAMESPACE="taskflow-demo"

mkdir -p "$MANIFEST_DIR"

for _ in $(seq 1 60); do
  if kubectl version --client >/dev/null 2>&1 && kubectl get nodes >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - >/dev/null

cat > "$MANIFEST_DIR/broken_api_service.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  namespace: taskflow-demo
  labels:
    app: api-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
        - name: api-service
          image: busybox:1.36
          command:
            - sh
            - -c
            - |
              echo "TaskFlow Demo api-service starting"
              if [ -z "${TASKFLOW_REQUIRED_CONFIG:-}" ]; then
                echo "Missing required application configuration"
                echo "Startup failed"
                exit 1
              fi
              echo "Found required application configuration"
              echo "Synthetic api-service is running"
              while true; do sleep 30; done
          env:
            - name: TASKFLOW_CONFIG_VALUE
              value: "present-but-not-the-required-key"
EOF

cat > "$MANIFEST_DIR/fixed_api_service.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  namespace: taskflow-demo
  labels:
    app: api-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
        - name: api-service
          image: busybox:1.36
          command:
            - sh
            - -c
            - |
              echo "TaskFlow Demo api-service starting"
              if [ -z "${TASKFLOW_REQUIRED_CONFIG:-}" ]; then
                echo "Missing required application configuration"
                echo "Startup failed"
                exit 1
              fi
              echo "Found required application configuration"
              echo "Synthetic api-service is running"
              while true; do sleep 30; done
          env:
            - name: TASKFLOW_REQUIRED_CONFIG
              value: "training-config-present"
EOF

cat > "$LAB_DIR/incident_notes.md" <<'EOF'
# Incident Notes Template

## Status

Write one sentence describing the current state.

## Impact

What user-facing workflow or service appears affected?

## Evidence

What pod status, events, logs, or deployment details support your current view?

## Failure Category

What category does the evidence point toward?

## Action Taken

What did you apply or change?

## Verification

How did you confirm recovery?

## Unknowns

What should not be assumed from this first pass?
EOF

cat > /usr/local/bin/check-crashloop-notes <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${LAB_DIR:-/root/taskflow-crashloopbackoff-lab}"
NOTES="$LAB_DIR/incident_notes.md"

if [ ! -f "$NOTES" ]; then
  echo "Notes file not found: $NOTES"
  exit 1
fi

score=0
checks=0

check_term() {
  local label="$1"
  local pattern="$2"
  checks=$((checks + 1))
  if grep -Eiq "$pattern" "$NOTES"; then
    echo "OK: mentions $label"
    score=$((score + 1))
  else
    echo "Check: add a note about $label"
  fi
}

check_term "api-service" "api-service"
check_term "CrashLoopBackOff" "CrashLoopBackOff"
check_term "logs" "logs?"
check_term "configuration" "config|configuration"
check_term "verified recovery" "verified recovery|Running|rollout|recovered"

echo
if [ "$score" -ge 4 ]; then
  echo "Good first-pass CrashLoopBackOff note. You captured the shape of the incident and recovery evidence."
else
  echo "Keep tightening the note: include service, symptom, evidence, configuration category, and recovery verification."
fi
EOF

chmod +x /usr/local/bin/check-crashloop-notes

kubectl apply -f "$MANIFEST_DIR/broken_api_service.yaml" >/dev/null
sleep 5

echo "Synthetic TaskFlow Demo CrashLoopBackOff lab is ready."
echo "Workspace: $LAB_DIR"
echo "Namespace: $NAMESPACE"

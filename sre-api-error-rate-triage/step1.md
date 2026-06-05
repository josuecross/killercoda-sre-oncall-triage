# Step 1: Read the alert and confirm service state

Your first job is to understand the alert and confirm whether the service is reachable.

Run:

```bash
cat /root/taskflow-sre-triage/alert.txt
cat /root/taskflow-sre-triage/service_status.txt
docker ps --filter name=taskflow-api
curl -i http://localhost:18080/healthz
```

The synthetic API uses host port `18080` by default. If you intentionally override `TASKFLOW_PORT` during setup, use that port in your `curl` commands instead.

Think through:

- What is the alert saying?
- Is the service container running?
- Is the service completely down?
- What is still unknown?

Write short notes before moving on. Good incident response starts with a clear problem statement, not a confident guess.

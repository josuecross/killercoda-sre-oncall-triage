# Step 1: Open the incident

Start by reading the alert and confirming whether the service process is reachable.

Run:

```bash
cat /root/taskflow-sre-triage/alert.txt
cat /root/taskflow-sre-triage/service_status.txt
docker ps --filter name=taskflow-api
curl -sS http://localhost:18080/healthz
```

If `/healthz` returns `ok`, the service process is reachable. That does not mean every workflow is healthy.

Before moving on, write down:

- What alert fired?
- Which service is affected?
- Which workflow appears affected?
- Is the service completely unavailable, or partially degraded?
- What is still unknown?

A good first triage pass starts with a clear problem statement, not a confident guess.

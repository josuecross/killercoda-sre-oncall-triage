Start by opening the incident and confirming whether the service process is reachable.

```bash
cat /root/taskflow-sre-triage/alert.txt
cat /root/taskflow-sre-triage/service_status.txt
docker ps --filter name=taskflow-api
curl -sS http://localhost:18080/healthz
```

If `/healthz` returns `ok`, the process is reachable. That does not mean every workflow is healthy.

Before moving on, identify:

* The alert that fired
* The affected service
* The affected workflow
* Whether this looks like total outage or partial degradation
* What is still unknown

A strong first triage pass starts with a clear problem statement, not a confident guess.

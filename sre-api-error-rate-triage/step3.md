Use recent logs to confirm the pattern you saw from requests and metrics.

```bash
docker logs taskflow-api --tail 20
docker logs taskflow-api 2>&1 | grep "status=500" | tail -5
docker logs taskflow-api 2>&1 | grep "workflow=task-create" | tail -10
docker logs taskflow-api 2>&1 | awk '/status=500/ {errors++} /status=/ {total++} END {print "errors=" errors+0, "total=" total+0}'
```

Review the triage runbook excerpt:

```bash
cat /root/taskflow-sre-triage/runbook_excerpt.md
```

Decide:

* What evidence supports `SEV-3 / Medium`?
* What would make you escalate?
* What evidence is still missing?
* What root cause should you avoid assuming too early?

Logs support the incident pattern. They do not, by themselves, prove the final cause.

# Step 3: Inspect logs and estimate impact

Use container logs to inspect the pattern. Treat logs as evidence, not final proof.

Run:

```bash
docker logs taskflow-api --tail 50
docker logs taskflow-api 2>&1 | grep "status=500"
docker logs taskflow-api 2>&1 | grep "workflow=task-create"
docker logs taskflow-api 2>&1 | awk '/status=500/ {errors++} /status=/ {total++} END {print "errors=" errors+0, "total=" total+0}'
```

Review the synthetic runbook excerpt:

```bash
cat /root/taskflow-sre-triage/runbook_excerpt.md
```

Ask:

- What evidence supports SEV-3 / Medium?
- What would make you escalate?
- What root cause should you not assume yet?

For this teaser, the starting hypothesis is usually SEV-3 / Medium unless broader impact evidence appears. That is not a final answer. It is an initial classification that should change if the evidence changes.

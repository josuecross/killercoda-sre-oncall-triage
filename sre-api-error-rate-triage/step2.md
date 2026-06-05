# Step 2: Inspect Synthetic Evidence

Now inspect the supporting evidence. Treat the files as clues, not proof.

Run:

```bash
cat /root/taskflow-sre-triage/metrics_snapshot.txt
cat /root/taskflow-sre-triage/api_logs_excerpt.txt
```

Look for:

- The primary signal.
- Supporting signals.
- Whether the issue appears total or partial.
- Which request path appears most affected.
- What evidence is still missing.

In this scenario, error rate is the primary signal. Latency is mildly elevated, but it is a supporting signal. Logs can show patterns, but a short log excerpt is not enough to declare root cause.

Avoid saying "the cause is..." too early. A stronger first-pass statement is: "The evidence currently suggests..."

# Step 2: Reproduce the degraded workflow

Now compare a read-only path with the write path that triggered the alert.

Run:

```bash
curl -sS http://localhost:18080/tasks
curl -sS -X POST http://localhost:18080/tasks
```

Generate a small sample of `task-create` requests and summarize the status codes:

```bash
for i in {1..12}; do curl -s -o /dev/null -w "%{http_code}\n" -X POST http://localhost:18080/tasks; done | sort | uniq -c
```

Check the training API metrics:

```bash
curl -sS http://localhost:18080/metrics
```

What to notice:

- `GET /tasks` represents a read path.
- `POST /tasks` represents the `task-create` workflow.
- Some `task-create` requests fail.
- The service is degraded, not fully unavailable.
- Error rate is the main signal.

Do not name a final root cause yet. At this stage, your job is to describe the failure pattern.

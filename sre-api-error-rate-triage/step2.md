# Step 2: Reproduce the degraded workflow

Now compare a read-only workflow with the task-create workflow.

Run:

```bash
curl -i http://localhost:18080/tasks
curl -i -X POST http://localhost:18080/tasks
```

Then generate a small sample of task-create requests:

```bash
for i in {1..12}; do curl -s -o /dev/null -w "%{http_code}\n" -X POST http://localhost:18080/tasks; done
```

Check the synthetic metrics endpoint:

```bash
curl -s http://localhost:18080/metrics
```

Look for:

- Whether read-only `GET /tasks` behaves differently from `POST /tasks`.
- Whether task-create is degraded.
- Whether the service is fully down or partially degraded.
- Whether error rate is the primary signal.

Avoid saying "the cause is..." too early. A stronger first-pass statement is: "The evidence currently suggests..."

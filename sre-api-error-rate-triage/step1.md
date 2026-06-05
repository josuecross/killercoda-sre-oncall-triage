# Step 1: Read The Alert

Your first job is to understand the alert without guessing the root cause.

Run:

```bash
cat /root/taskflow-sre-triage/alert.txt
cat /root/taskflow-sre-triage/service_status.txt
```

Think through:

- What is the alert saying?
- Which service is affected?
- Is the service completely down?
- What do you know?
- What is still unknown?

Write short notes before moving on. Good incident response starts with a clear problem statement, not a confident guess.

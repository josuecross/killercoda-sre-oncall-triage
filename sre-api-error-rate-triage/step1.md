# Step 1: Read The Alert

Your first job is to understand the alert without guessing the root cause.

`taskflowctl` is a synthetic helper command for this lab. It reads the fictional TaskFlow Demo evidence created during setup.

Run:

```bash
taskflowctl alert
taskflowctl status
```

Think through:

- What is the alert saying?
- Which service is affected?
- Is the service completely down?
- What do you know?
- What is still unknown?

Write short notes before moving on. Good incident response starts with a clear problem statement, not a confident guess.

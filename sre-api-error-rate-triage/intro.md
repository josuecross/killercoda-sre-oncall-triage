# Welcome to the Incident Room

You are the on-call responder for TaskFlow Demo. A 5xx error-rate alert fired for `api-service`, and your job is to make the first triage pass.

In this lab, you will inspect a running training API using real terminal commands:

- `curl`
- `docker logs`
- `grep`
- `awk`
- `nano`
- `cat`

You will confirm service state, reproduce the degraded `task-create` workflow, inspect logs, compare read and write paths, estimate impact, classify severity, and draft the first stakeholder update.

The goal is practical incident judgment: identify what is known, what is still unknown, what should be communicated now, and what should be investigated next.

Clean-room note: TaskFlow Demo and all evidence in this lab are fictional training material.

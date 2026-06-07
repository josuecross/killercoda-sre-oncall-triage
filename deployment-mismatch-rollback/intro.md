You are the on-call responder for TaskFlow Demo. A deployment completed, health checks pass, but a `task-create` workflow is failing.

Your job is to compare release and runtime state, inspect logs, decide rollback vs fix-forward, verify recovery, and draft a first update.

You will use real terminal commands:

* `curl`
* `docker logs`
* `grep`
* `awk`
* `nano`
* `cat`

Focus on practical incident judgment: a healthy process does not always mean a healthy release. Compare the intended release state with the running runtime state before choosing mitigation.

Clean-room note: TaskFlow Demo and all evidence in this lab are fictional training material.

You are the on-call responder for TaskFlow Demo. A deployment left `api-service` in `CrashLoopBackOff`, and your job is to make the first Kubernetes triage pass.

You will inspect pod status, review events and logs, identify the failure category, apply a safe fix-forward, verify recovery, and write a short incident update.

You will use real Kubernetes commands:

* `kubectl get pods`
* `kubectl describe pod`
* `kubectl logs`
* `kubectl apply`
* `kubectl rollout status`
* `kubectl get deployment`
* `nano` or `cat`

Focus on practical incident judgment: what is failing, what evidence supports the current hypothesis, what is still unknown, and what should be communicated now.

Clean-room note: TaskFlow Demo and all evidence in this lab are fictional training material.

Open the incident and decide whether the service is unreachable or whether one workflow is degraded after a deployment.

Before using the commands, answer:

* Is the service reachable?
* Does health passing mean the workflow is healthy?
* Which workflow appears affected?
* What evidence is still missing?
* What should be communicated now?

<details>
<summary>Need a hint?</summary>

Start with reachability, then test the read and write paths separately. A release can pass health checks while one workflow fails.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>cat /root/taskflow-release-lab/incident_notes.md
docker ps --filter name=taskflow-release
curl -sS http://localhost:18082/healthz
curl -sS http://localhost:18082/status
curl -sS http://localhost:18082/tasks
curl -sS -X POST http://localhost:18082/tasks
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

Health passes and the read path works, but `task-create` fails. That points to workflow degradation, not total service outage.

</details>

Before continuing, write one sentence that separates service reachability from workflow health.

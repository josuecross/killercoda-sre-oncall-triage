Open the incident and decide whether this looks like a full outage or degraded async processing.

Before using the commands, answer:

* What component is degraded?
* Is the training service reachable?
* Is this a full outage or async processing degradation?
* What evidence is still missing?
* What should be communicated now?

<details>
<summary>Need a hint?</summary>

Queue alerts often mean background work is delayed while the request path may still be reachable. Confirm service reachability, then look at queue depth and oldest message age.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>cat /root/taskflow-queue-lab/incident_notes.md
docker ps --filter name=taskflow-queue
curl -sS http://localhost:18081/healthz
curl -sS http://localhost:18081/status
curl -sS http://localhost:18081/metrics
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

The container should be running and `/healthz` should return `ok`. The status output should say `notification-worker` is degraded. Metrics should show queue depth and oldest message age.

</details>

Before continuing, write one sentence describing the incident without naming a final root cause.

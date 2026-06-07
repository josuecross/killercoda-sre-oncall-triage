Inspect queue metrics and logs to determine whether the backlog is growing, stable, or draining.

Before using the commands, answer:

* Is queue depth growing, stable, or draining?
* Is oldest message age increasing?
* Does worker capacity look lower than incoming work?
* What user-facing impact would you communicate?
* What should you avoid claiming as final root cause?

<details>
<summary>Need a hint?</summary>

One metrics snapshot is useful, but trend matters more. Compare repeated snapshots and then use logs to confirm whether the worker is falling behind.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>for i in {1..4}; do curl -sS http://localhost:18081/metrics; echo "---"; sleep 2; done
docker logs taskflow-queue --tail 30
docker logs taskflow-queue 2>&1 | grep "queue_depth" | tail -10
docker logs taskflow-queue 2>&1 | awk '/queue_depth=/ {count++} END {print "queue_metric_lines=" count+0}'
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

Queue depth and oldest message age should show backlog pressure. Logs should show `backlog_growing` or similar. This supports degraded async processing, not total outage.

</details>

Before continuing, decide what evidence supports `SEV-3 / Medium` and what would make you escalate.

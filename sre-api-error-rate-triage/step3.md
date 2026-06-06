Use logs to confirm the pattern and estimate current impact.

Before using the commands, answer:

* Do logs support the failure pattern?
* Are failures concentrated around `task-create`?
* What evidence supports `SEV-3 / Medium`?
* What would make you escalate?
* What root cause should you avoid assuming too early?

<details>
<summary>Need a hint?</summary>

Logs are evidence, not proof of final cause. Look for pattern, scope, and impact. A useful first-pass triage note should explain what is affected and what is still unknown.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>docker logs taskflow-api --tail 20
docker logs taskflow-api 2&gt;&amp;1 | grep "status=500" | tail -5
docker logs taskflow-api 2&gt;&amp;1 | grep "workflow=task-create" | tail -10
docker logs taskflow-api 2&gt;&amp;1 | awk '/status=500/ {errors++} /status=/ {total++} END {print "errors=" errors+0, "total=" total+0}'
cat /root/taskflow-sre-triage/runbook_excerpt.md
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

Logs should show `status=500` events for `task-create`. The count command should show nonzero errors. The runbook should point toward `SEV-3 / Medium` unless broader impact appears.

</details>

Before continuing, decide what you would communicate now and what you would avoid claiming.

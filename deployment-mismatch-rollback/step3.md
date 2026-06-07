Choose a mitigation and verify whether the affected workflow recovers.

In a real incident, rollback and fix-forward both require context. In this training scenario, rollback is the safe default because it returns the API version and config to a compatible pair.

Before using the commands, answer:

* What mitigation did you choose?
* Did the release/config pair become compatible?
* Did `task-create` recover?
* What evidence would you need before closing the incident?
* What would make this `SEV-2`?

<details>
<summary>Need a hint?</summary>

Do not stop at the mitigation command. Check version, config, the affected workflow, and metrics after applying the rollback.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>curl -sS -X POST http://localhost:18082/mitigate/rollback
curl -sS http://localhost:18082/version
curl -sS http://localhost:18082/config
curl -sS -X POST http://localhost:18082/tasks
curl -sS http://localhost:18082/metrics
docker logs taskflow-release --tail 40
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

Rollback moves the API and ruleset to compatible versions. `POST /tasks` should succeed. Metrics should show mitigation was applied and the mismatch cleared.

</details>

Before continuing, summarize the mitigation and recovery evidence in plain language.

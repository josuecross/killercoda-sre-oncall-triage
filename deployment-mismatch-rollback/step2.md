Compare the intended release state with the runtime state.

Before using the commands, answer:

* What version is running?
* What ruleset or config does the release expect?
* What ruleset or config is actually running?
* What evidence supports a mismatch hypothesis?
* What should you avoid claiming too early?

<details>
<summary>Need a hint?</summary>

Look for disagreement between version, release, and config outputs. Then use logs to confirm whether the mismatch appears near failing `task-create` requests.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>curl -sS http://localhost:18082/version
curl -sS http://localhost:18082/release
curl -sS http://localhost:18082/config
curl -sS http://localhost:18082/metrics
docker logs taskflow-release --tail 40
docker logs taskflow-release 2>&1 | grep "mismatch" | tail -10
docker logs taskflow-release 2>&1 | awk '/mismatch/ {m++} /task-create/ {t++} END {print "mismatch_lines=" m+0, "task_create_lines=" t+0}'
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

Version, release, and config state disagree. Logs support a release/config mismatch affecting `task-create`. This is enough to choose a safe training mitigation, but not enough for a full postmortem.

</details>

Before continuing, decide what evidence supports rollback versus fix-forward.

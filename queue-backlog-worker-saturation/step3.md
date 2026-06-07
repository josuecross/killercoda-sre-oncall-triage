Apply a safe training mitigation and verify whether the backlog stabilizes or starts draining.

Before using the commands, answer:

* What mitigation will you apply?
* Did worker capacity change?
* Did queue depth stop growing or start draining?
* What evidence would you need before closing the incident?
* What would make this `SEV-2` instead of `SEV-3`?

<details>
<summary>Need a hint?</summary>

In this lab, the safe mitigation is to increase worker capacity. After mitigation, verify with repeated metrics and logs rather than assuming the first successful command means recovery.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>curl -sS -X POST http://localhost:18081/simulate/burst
curl -sS http://localhost:18081/metrics
curl -sS -X POST http://localhost:18081/mitigate/scale-workers
for i in {1..6}; do curl -sS http://localhost:18081/metrics; echo "---"; sleep 2; done
docker logs taskflow-queue --tail 40
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

After mitigation, worker capacity should increase and queue depth should stabilize or decrease. That is recovery evidence for the training scenario.

</details>

Before continuing, summarize the mitigation and the verification signal in plain language.

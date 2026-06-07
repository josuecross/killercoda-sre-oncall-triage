Write the first stakeholder update. Keep it short, specific, and evidence-based.

Your update should include:

* Status
* Impact
* Current evidence
* Initial severity
* Mitigation
* Verification
* Next update time
* Unknowns

<details>
<summary>Need a hint?</summary>

A useful first update says the service is reachable, `task-create` was degraded, release/config state was inconsistent, rollback was applied in the training scenario, and recovery was verified with a successful `task-create` request.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>nano /root/taskflow-release-lab/incident_notes.md
cat /root/taskflow-release-lab/incident_notes.md
check-release-notes
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

`check-release-notes` should give constructive feedback about missing sections and useful reasoning terms. It should not provide the final answer key.

</details>

Before finishing, run `check-release-notes` after writing your notes.

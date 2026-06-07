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

A strong first update should say that async notifications are delayed, the platform is not fully down based on current evidence, the backlog trend was observed, mitigation was applied, and recovery is being verified.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>nano /root/taskflow-queue-lab/incident_notes.md
cat /root/taskflow-queue-lab/incident_notes.md
check-queue-notes
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

`check-queue-notes` should give constructive feedback about missing sections and useful reasoning terms. It should not provide the final answer key.

</details>

Before finishing, run `check-queue-notes` after writing your notes.

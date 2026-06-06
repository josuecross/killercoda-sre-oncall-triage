Write the first stakeholder update. Keep it short, specific, and evidence-based.

Your update should include:

* Status
* Impact
* Current evidence
* Initial severity
* Next action
* Next update time
* Unknowns

<details>
<summary>Need a hint?</summary>

A strong first update is calm and specific. It should say what is known, what is unknown, what is being checked next, and when the next update will happen. It should not pretend to know the final cause.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>nano /root/taskflow-sre-triage/incident_notes.md
cat /root/taskflow-sre-triage/incident_notes.md
check-triage
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

`check-triage` should give constructive feedback about missing sections and useful reasoning terms. It should not provide the final answer.

</details>

Before finishing, run `check-triage` after writing your notes.

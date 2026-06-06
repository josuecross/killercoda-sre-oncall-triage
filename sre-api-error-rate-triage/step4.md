# Step 4: Write the first update

Now write the first incident update. Keep it short, specific, and evidence-based.

Open the notes template:

```bash
nano /root/taskflow-sre-triage/incident_notes.md
```

If you prefer to inspect the template before editing:

```bash
cat /root/taskflow-sre-triage/incident_notes.md
```

Fill in:

- Status
- Impact
- Current evidence
- Initial severity
- Next action
- Next update time
- Unknowns

After writing your notes, run:

```bash
check-triage
```

Your first update should tell people what is known, what is still unknown, and what you are doing next. Do not claim a final root cause yet.

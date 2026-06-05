# Step 4: Draft The First Update

Now draft a first stakeholder update. Keep it calm, short, and evidence-based.

Run:

```bash
taskflowctl notes
nano /root/taskflow-sre-triage/incident_notes.md
check-triage
```

If you do not want to edit the file, you can still read the template:

```bash
cat /root/taskflow-sre-triage/incident_notes.md
```

Draft these fields:

- Status
- Impact
- Current evidence
- Next action
- Next update time

After writing your notes, run:

```bash
check-triage
```

Use plain language. Do not claim a final root cause yet. Your first update should tell people what is known, what is unknown, and what you are doing next.

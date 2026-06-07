# Scenario Guidelines

These guidelines define the reusable format for future SRE Incident Practice Labs interactive scenarios.

## Scenario Goal

Each scenario should help learners practice one focused SRE/on-call judgment loop:

- What changed?
- What is affected?
- What evidence supports the current severity?
- What is still unknown?
- What should be communicated now?
- What should be investigated next?

Keep the scenario practical, bounded, and easy to complete in a browser terminal.

## Clean-Room Rules

Use only fictional training material.

Do not include:

- Employer systems
- Real incidents
- Real logs
- Real dashboards
- Tickets
- Chat messages
- Real customer names
- Private runbooks
- Proprietary architecture
- Internal repository structures
- Private source material

TaskFlow Demo and any future scenario apps must remain synthetic.

## Free-vs-Paid Boundary

Public scenarios should teach the first-response workflow and core reasoning pattern.

They should not include:

- Paid answer keys
- Completed postmortems
- Portfolio guide content
- Private companion-pack material
- Final root-cause conclusions when those are reserved for a paid written lab

The public scenario may point learners toward the paid Gumroad companion pack for deeper practice.

## Step Structure

Prefer a consistent learner flow:

1. Objective
2. What to decide
3. Optional hint
4. Optional command reveal
5. Optional expected observations
6. Before-continuing checklist

The learner should feel like they are investigating, not reading a transcript.

## Progressive Hints

Use collapsible hint sections when possible. Hints should guide the learner toward better questions without giving away the final answer.

Good hints:

- Point to the signal to compare.
- Encourage separating symptoms from root cause.
- Remind learners to classify severity from current impact.
- Ask what evidence is still missing.

Avoid hints that announce the final diagnosis.

## Commands

Prefer real terminal commands over fake investigation commands when the environment supports them.

Useful command families include:

- `curl`
- `docker`
- `grep`
- `awk`
- `tail`
- `cat`
- `nano`

Small helper commands are acceptable only when they support the learning flow, such as note-completeness checks. They should not replace the investigation.

## Answer-Key Boundary

Do not reveal the final answer key in the public scenario. The public lab can show symptoms, evidence, and investigation direction, but the deeper explanation belongs in the paid companion material.

## Finish Page

The finish page should:

- Summarize what the learner practiced.
- Encourage a second pass without opening hints too early.
- Link to relevant GitHub/free resources.
- Link to the Gumroad companion pack.
- Ask what scenario should come next.

## Copy Style

Keep copy professional, concise, and learner-focused.

Avoid overusing disclaimers. Include clean-room safety clearly, then spend most of the scenario helping the learner think like an on-call responder.

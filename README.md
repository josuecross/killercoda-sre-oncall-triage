# SRE Incident Practice Labs — Interactive Scenarios

This repo contains free guided browser scenarios for SRE and on-call practice.

The scenarios are clean-room training material. Learners use realistic incident-response workflows and real terminal commands where useful, while all services, alerts, logs, metrics, and evidence remain fictional.

## Current Scenarios

| Scenario | Status | What learners practice | Link |
| --- | --- | --- | --- |
| API Error Rate Alert | Live | Alert triage, `curl`, Docker logs, `grep`, `awk`, severity, first stakeholder update | https://killercoda.com/josuecross/scenario/sre-api-error-rate-triage |

## Current Live Scenario

**SRE On-Call Triage: API Error Rate Alert**

https://killercoda.com/josuecross/scenario/sre-api-error-rate-triage

In this scenario, learners act as the on-call responder for TaskFlow Demo, inspect a running training API, reproduce intermittent 5xx failures, review logs, estimate impact, classify severity, and draft a first stakeholder update.

## Planned Scenarios

- CrashLoopBackOff interactive scenario
- Queue backlog / worker saturation
- Noisy alert / false positive
- Deployment rollback decision
- Weak postmortem action items

## Paid Companion Pack

The paid companion pack is sold separately on Gumroad. It includes deeper written labs, answer keys, completed postmortems, portfolio guidance, and local practice materials.

Main paid companion pack:

https://cruzer480.gumroad.com/l/cwepcj

A lower-cost single CrashLoopBackOff kit is also available separately:

https://cruzer480.gumroad.com/l/sre-crashloopbackoff-kit

This public repo should not include paid answer keys, completed postmortems, portfolio guides, ZIP packages, or private companion-pack source files.

## Clean-Room Note

TaskFlow Demo and all scenario evidence are fictional training material. Do not add real incidents, real logs, real dashboards, tickets, chat messages, private runbooks, employer systems, customer names, or proprietary architecture to this repo.

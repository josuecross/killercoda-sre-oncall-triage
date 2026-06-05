# SRE On-Call Triage: API Error Rate Alert

This is a fictional SRE/on-call triage scenario for the SRE Incident Practice Labs product line.

TaskFlow Demo is a synthetic B2B task-management SaaS. In this teaser, you are the on-call responder for the fictional `api-service`. An alert has fired because the API 5xx error rate has stayed above threshold for 12 minutes.

This lab now uses a real synthetic containerized API on `localhost:18080` by default so you can practice with normal terminal tools. You will use `curl`, `docker logs`, `grep`, `awk`, `nano`, and `cat` to inspect the service, compare workflows, estimate impact, and draft a first update.

This is not a Kubernetes lab, not a production simulator, and not a memorization exercise. The goal is incident judgment:

- What is the alert actually saying?
- Is the service reachable?
- Which workflow looks degraded?
- What is still unknown?
- How severe does this look right now?
- What should you communicate first?
- What should you investigate next?

Everything in this scenario is fictional and synthetic. It is not based on real incidents, real systems, real logs, dashboards, tickets, private runbooks, customer data, or proprietary architecture.

This public teaser only covers a first-pass triage workflow.

Inspect pod events and logs to understand why the container is restarting.

Before using the commands, answer:

* Which pod should you inspect?
* Do events show restart or backoff behavior?
* Do logs show startup failure?
* Do previous logs add useful context?
* What should you avoid assuming too early?

<details>
<summary>Need a hint?</summary>

For restart loops, the current container may exit quickly. Use `describe` for events and try both current and previous logs. Logs can identify the failure category without proving the full incident story.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>POD="$(kubectl get pods -n taskflow-demo -l app=api-service -o jsonpath='{.items[0].metadata.name}')"
echo "$POD"
kubectl describe pod "$POD" -n taskflow-demo
kubectl logs "$POD" -n taskflow-demo
kubectl logs "$POD" -n taskflow-demo --previous || true
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

Events should show restart or backoff behavior. Logs should show startup failure caused by missing required application configuration. That is enough to identify the category, but not enough to write a completed postmortem.

</details>

Before continuing, decide what evidence supports a configuration-related startup failure.

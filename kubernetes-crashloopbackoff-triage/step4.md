Apply the safe fix-forward, verify recovery, and write the first incident update.

Before using the commands, answer:

* What will change when you apply the fixed manifest?
* How will you know the rollout succeeded?
* What pod state should you expect after recovery?
* What log lines would confirm the service is staying up?
* What should your first update include?

<details>
<summary>Need a hint?</summary>

Verification should include more than applying the file. Check rollout status, pod state, and logs from the current pod before saying the service recovered.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>kubectl apply -f /root/taskflow-crashloopbackoff-lab/manifests/fixed_api_service.yaml
kubectl rollout status deployment/api-service -n taskflow-demo
kubectl get pods -n taskflow-demo
POD="$(kubectl get pods -n taskflow-demo -l app=api-service -o jsonpath='{.items[0].metadata.name}')"
kubectl logs "$POD" -n taskflow-demo
nano /root/taskflow-crashloopbackoff-lab/incident_notes.md
check-crashloop-notes
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

The Deployment should roll out successfully. A new pod should reach `Running`. Logs should show required configuration was found and the synthetic service is running.

</details>

Before finishing, run `check-crashloop-notes` after writing your update.

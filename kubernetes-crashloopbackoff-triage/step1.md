Start by opening the incident and deciding whether the Kubernetes objects exist and whether the pod is healthy.

Before using the commands, answer:

* Which namespace should you inspect?
* Which Deployment is affected?
* Is the Deployment present?
* Is the pod running, restarting, or unavailable?
* What is still unknown?

<details>
<summary>Need a hint?</summary>

Start broad: namespace, Deployment, then Pods. A `CrashLoopBackOff` may take a little time to appear, so repeated restarts or `Error` can still support the same failure pattern early in the lab.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>kubectl get namespace taskflow-demo
kubectl get deployment api-service -n taskflow-demo
kubectl get pods -n taskflow-demo
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

The namespace and Deployment should exist. The `api-service` pod should not be healthy. Depending on timing, it may show `Error`, `CrashLoopBackOff`, or repeated restarts.

</details>

Before continuing, write one sentence that describes the incident without naming a final root cause.

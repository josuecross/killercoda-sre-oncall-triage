Reproduce the workflow that triggered the alert and compare it with a read-only path.

Before using the commands, answer:

* Does the read path behave differently from the write path?
* Which workflow appears most affected?
* Is the service down or degraded?
* What signal should you trust most right now?

<details>
<summary>Need a hint?</summary>

Compare `GET /tasks` with `POST /tasks`. A partial failure often affects one workflow more than another.

</details>

<details>
<summary>Need the commands?</summary>

<pre><code>curl -sS http://localhost:18080/tasks
curl -sS -X POST http://localhost:18080/tasks
for i in {1..12}; do curl -s -o /dev/null -w "%{http_code}\n" -X POST http://localhost:18080/tasks; done | sort | uniq -c
curl -sS http://localhost:18080/metrics
</code></pre>

</details>

<details>
<summary>What should you notice?</summary>

`GET /tasks` should succeed. `POST /tasks` should show intermittent failures. The metrics endpoint should show `task-create` errors. This supports degraded service, not total outage.

</details>

Before continuing, describe the failure pattern in plain language.

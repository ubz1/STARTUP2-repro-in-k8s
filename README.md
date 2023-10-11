# STARTUP2-repro-in-k8s

let 

```
./run.sh
```

create the conditions where you can add the slow node (= the pod of deploy-04s)

if there is enough sample data the slow node will be in STARTUP2 for long enough to test election behavior.

# add a new node, it will be slow

# experiment 1:
```
rs.add({ host: '10-42-0-213.namespace123.pod.cluster.local:27017',priority: 0, votes: 0})
e=rs.config()
e.members[2].votes=1
e.members[2].priority=1
rs.reconfig(e,{force:1})
```

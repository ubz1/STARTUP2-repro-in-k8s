# replace namespace123 with your namespace

pkill -f 'port-forward'
kubectl delete deployment.apps/mongo-01
kubectl delete deployment.apps/mongo-02
kubectl delete deployment.apps/mongo-03
kubectl delete deployment.apps/mongo-04
kubectl delete configmap mongod-01-conf
kubectl delete configmap mongod-02-conf
kubectl delete configmap mongod-03-conf
kubectl create configmap mongod-01-conf --from-file=key1=mongod-01.conf
kubectl create configmap mongod-02-conf --from-file=key2=mongod-02.conf
kubectl create configmap mongod-03-conf --from-file=key3=mongod-03.conf
kubectl create -f deploy-01.yaml
kubectl create -f deploy-02.yaml
kubectl create -f deploy-03.yaml
kubectl create -f deploy-04s.yaml # s for slow
sleep 20
pod1=$(kubectl get all |grep --colour=never 'pod/mongo-01'|cut -f1 -d' ')
pod2=$(kubectl get all |grep --colour=never 'pod/mongo-02'|cut -f1 -d' ')
pod3=$(kubectl get all |grep --colour=never 'pod/mongo-03'|cut -f1 -d' ')
pod4=$(kubectl get all |grep --colour=never 'pod/mongo-04'|cut -f1 -d' ')

echo pod1 is $pod1
kubectl port-forward $pod1 40000:27017 &

IP1=$(kubectl describe $pod1 | grep --colour=never 'IP:' | tail -1|sed 's/IP: //')
IP2=$(kubectl describe $pod2 | grep --colour=never 'IP:' | tail -1|sed 's/IP: //')
IP3=$(kubectl describe $pod3 | grep --colour=never 'IP:' | tail -1|sed 's/IP: //')
IP4=$(kubectl describe $pod4 | grep --colour=never 'IP:' | tail -1|sed 's/IP: //')
IP1d=$(echo $IP1|tr '\.' '-')
IP2d=$(echo $IP2|tr '\.' '-')
IP3d=$(echo $IP3|tr '\.' '-')
IP4d=$(echo $IP4|tr '\.' '-')

echo $IP1
echo $IP2
echo $IP3
echo $IP4

echo $IP1d
echo $IP2d
echo $IP3d
echo $IP4d

mongosh --port 40000 --eval 'rs.initiate(
   {
      _id: "rs",
      version: 1,
      members: [
         { _id: 0, host : "'$IP1d'.namespace123.pod.cluster.local:27017", priority: 10 },
         { _id: 1, host : "'$IP2d'.namespace123.pod.cluster.local:27017" },
         { _id: 2, host : "'$IP3d'.namespace123.pod.cluster.local:27017" }
      ]
   }
)
'

sleep 30

mongorestore --port 40000 ~/Documents/sample_data/

mongosh --port 40000 

# add a new node, it will be slow

rs.add({ host: '10-42-0-213.namespace123.pod.cluster.local:27017',priority: 0, votes: 0})

e=rs.config()
e.members[2].votes=1
e.members[2].priority=1
rs.reconfig(e,{force:1})






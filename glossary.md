High Availability Jargon and Acronyms Glossary
==============================================

### Cluster Resource Manager

Starts and stops resources on nodes, coordinating them to ensure high availability of resources.

### DRBD

https://en.wikipedia.org/wiki/Distributed_Replicated_Block_Device

Distributed Replicated Block Device. A distributed, replicated storage system.

### Heartbeat Network

https://en.wikipedia.org/wiki/Heartbeat_network

A private network which is shared only by the nodes in the cluster, so that they can exchange messages, and know when a node goes down or comes back up. Also known as Cluster Messaging Layer.

### Local Resource Manager

Performs operations on local resources on behalf of the cluster resource manager.

### Node Fencing

Monitors nodes to ensure they are properly coordinated, cutting them off from other parts of the system if they're misbehaving.

### OCF

Open Cluster Framework. A working group of the Free Standards Group, now part of the Linux Foundation.

### OCF Resource Agents

http://linux-ha.org/wiki/OCF_Resource_Agents

Scripts to provide resources to be managed by a cluster. These are basically an extension to LSB resource agents.

### Quorum

https://www.tech-coffee.net/understand-failover-cluster-quorum
https://blogs.msdn.microsoft.com/clustering/2011/05/27/understanding-quorum-in-a-failover-cluster

A mechanism to handle split brain or network partitioning using votes by nodes. So long as a majority of nodes are online and accessible to each other, the cluster continues to operate. Nodes in the minority become passive.

### Split Brain

https://en.wikipedia.org/wiki/Split-brain_(computing)

A situation where nodes are unable to communicate with each other, and each mistakenly believes themselves to be the only one alive, or part of the decision making group.

### STONITH

http://www.linux-ha.org/wiki/STONITH

Shoot The Other Node In The Head. A method of fencing that involves killing the errant node.

### STONITH Deathmatch

http://ourobengr.com/ha

A situation where two nodes believe the other is broken, and keep STONITHing each other. A shoots B. B reboots, shoots A. A reboots, shoots B, and so on.

### VRRP

https://en.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol

Virtual Router Redundancy Protocol. A protocol for creating virtual routers and IP addresses.

### Witness

A witness is a minimal node whose only real purpose is to bring the number of votes in a cluster to an odd number. It must be accessible to the other nodes, but doesn't need to be exposed.

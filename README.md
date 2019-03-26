Linux High Availability
=======================

Why do we need it?
------------------

Whether you are running a web application, file sharing, a database server, or anything serving users over a network, one thing that must always be contended with is downtime. The backend app may crash or stall. The network may go down. Someone might trip over a power cord. An automatic reboot might kick in due to misconfiguration. No matter how carefully you set things up, eventually something will cause your service to come crashing down at 3 am in the middle of your vacation trip to save your marriage.



What is high availaibilty?
--------------------------

High availability is a mechanism whereby multiple redundant services are leveraged to minimize interruptions. When one service goes down, another, identical service picks up the work. There are different ways to accomplish this:


### Network Level High Availability

High availability at the network level involves switching a virtual IP address between different nodes that run the same service. When a node goes offline, the virtual IP is switched over to another node running the same service. This functionality can also be used to provide load balancing, where the virtual IP address floats between servers during normal operation.

**Simplified view** (Virtual IP and Management are not separate machines)

               +------------+
               | Virtual IP |<------------+
               +------------+             |
                     |                    |
                     |                    |
         +-----------+ - - - - - +        |
         |                                |
         v           v           v        |
    +--------+  +--------+  +--------+    |
    | Node A |  | Node B |  | Node C |    |
    +--------+  +--------+  +--------+    |
         ^           ^           ^        |
         |           |           |        |
    +--------------------------------+    |
    |           Management           |----+
    +--------------------------------+

This kind of setup has the advantage of being simple, but it doesn't handle the failing services themselves. The downed service remains down, and must be restarted manually. If all redundant services eventually fail without someone intervening to restart them, the service goes offline completely. As well, this kind of setup has no way to detect misbehaving nodes. If a node is accepting network connections, it must be OK, even if the service inside the node is behaving badly. It's up to the nodes themselves to monitor their own health.

Since the management layer has no knowledge of what's inside the nodes, all services in the nodes must run simultaneously, which causes problems if they need to write to shared resources such as network filesystems. Corruption is likely unless the services or the shared resources are carefully designed to avoid it.


### Service Level High Availability

High availability at the service level is more complicated. The management layer must have knowledge about how to start, stop, and monitor services on nodes. This requires a special management communication channel to the nodes (heartbeat network).

    +-----------------------------+  +-----------------------------+
    |     Service X Interface     |  |     Service Y Interface     |
    +-----------------------------+  +-----------------------------+

    +--------------------------------------------------------------+
    |                         Management                           |
    +--------------------------------------------------------------+
           |   |                |   |                |   |      |
           v   |                v   |                v   |      |
    +----------|------+  +----------|------+  +----------|------|--+
    | Node A   |      |  | Node B   |      |  | Node C   |      |  |
    |          v      |  |          v      |  |          v      |  |
    |  +-----------+  |  |  +-----------+  |  |  +-----------+  |  |
    |  | Service X |  |  |  | Service Y |  |  |  | Service X |  |  |
    |  +-----------+  |  |  +-----------+  |  |  +-----------+  |  |
    |                 |  |                 |  |                 |  |
    +-----------------+  +-----------------+  |  +-----------+  |  |
                                              |  | Service Y |<-+  |
                                              |  +-----------+     |
                                              |                    |
                                              +--------------------+

The service interfaces can be via virtual IP or some other mechanism. Nodes can run any number of services. Management can run separately, or via a quorum protocol on the nodes themselves.

Since the management layer knows how to monitor services inside the nodes, it can ensure that at most one copy of a service is running at any given time, which means that they can write to shared resources without fear of corruption. As well, a misbehaving node can be detected and fenced (cut off so that it can do no damage), and then killed/restarted as needed.

Various node configurations are possible: https://en.wikipedia.org/wiki/High-availability_cluster#Node_configurations


Jargon and Acronyms
-------------------

See [glossary](glossary.md)



Checklist
---------

### Network or Service HA?

Do your primary and backup services need write access to shared storage?

* Yes: You need service HA

Does your backup service need information from the primary service to continue doing its job on a failover?

* Yes: You need service HA, and shared storage to share the required information.

### Service HA Compatibility

To be compatible with service HA, your service must:

* Be encapsulatable into a resource script (start, stop, status).
* Not corrupt data on crash or restart.



HA Technologies on Linux
------------------------

* [Keepalived](keepalived.md)
* [ClusterLabs](clusterlabs.md)

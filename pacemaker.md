Pacemaker
=========

https://clusterlabs.org

Pacemaker provides service level high availability, supporting practically any redundancy configuration in modern use.


### Main Components

* Pacemaker (cluster resource manager): Starts and stops services, makes sure only one instance of a service is running.
* Corosync (messaging layer): like dbus across nodes.
* Resource Agents: scripts that know how to control services.

Note: `heartbeat` is the old messaging layer, now deprecated.

### Other components

* Local Resource Manager: calls resource agent scripts
* Node Fencing: STONITH services, calls resource agent scripts
* Reporting


Quickstart
----------

[Here](pacemaker-quickstart)

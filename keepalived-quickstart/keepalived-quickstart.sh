#!/bin/bash

# keepalived-cloud-config.yaml:

# #cloud-config
#
# bootcmd:
#   # https://github.com/CanonicalLtd/multipass/issues/666
#   # DNS resolution workaround to be able to see sister nodes.
#   - sudo ln -fs /run/systemd/resolve/resolv.conf /etc/resolv.conf
#
# packages:
#   - keepalived
#   # An example service
#   - nginx

# -------------------------------------------------------------------

set -eu


echo "## Quickstart script to build a simple two-node highly available nginx service using keepalived."
echo
echo "This quickstart script uses multipass to create Ubuntu 18.10 nodes. You can of course deploy on containers, VMs, or bare metal."

if ! which multipass; then
    echo "You must install multipass to use this quickstart script."
    exit 1
fi

# -------------------------------------------------------------------

echo
echo "### Rebuilding ka-node1 and ka-node2"

multipass delete -p ka-node1 || true
multipass delete -p ka-node2 || true

multipass launch daily:cosmic --cloud-init ./keepalived-cloud-config.yaml --name ka-node1
multipass launch daily:cosmic --cloud-init ./keepalived-cloud-config.yaml --name ka-node2

# -------------------------------------------------------------------

echo
echo "### Gathering network information"

ip_node1=$(multipass exec ka-node1 -- ip addr | grep 'inet ' | grep global | head -1 | sed 's/.*inet \([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*/\1/g')
ip_node2=$(multipass exec ka-node2 -- ip addr | grep 'inet ' | grep global | head -1 | sed 's/.*inet \([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*/\1/g')
ip_dot3=$(multipass exec ka-node1 -- ip addr | grep 'inet ' | grep global | head -1 | sed 's/.*inet \([0-9]*\.[0-9]*\.[0-9]*\)\..*/\1.3/g')

echo "ka-node1 is at $ip_node1, ka-node2 is at $ip_node2, and our virtual IP will be at the .3 address of this subnet: $ip_dot3"

# -------------------------------------------------------------------

echo
echo "### We're using nginx as our highly available service. Create home pages so we can see when it's running."
echo
echo "Note: You'd normally use the same content on both sites, but we want to see via the browser which node is running!"

multipass exec ka-node1 -- sudo bash -c "echo '<html><h1>Primary</h1></html>' >/var/www/html/index.html"
multipass exec ka-node2 -- sudo bash -c "echo '<html><h1>Secondary</h1></html>' >/var/www/html/index.html"

# -------------------------------------------------------------------

echo
echo "### Configure keepalived"
echo
echo "We'll create a virtual IP address, set up a monitoring script for nginx, and tell the nodes how to reach each other."

multipass exec ka-node1 -- sudo bash -c "cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_script chk_nginx {
    script \"/usr/sbin/service nginx status\"
    interval 2
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    virtual_router_id 33
    state MASTER
    priority 200
    interface ens3
    advert_int 1
    accept
    unicast_src_ip $ip_node1
    unicast_peer {
    	$ip_node2
    }

    authentication {
        auth_type PASS
        auth_pass mypass
    }

    virtual_ipaddress {
        $ip_dot3
    }

    track_script {
        chk_nginx
    }
}
EOF"

# Differences: priority, unicast_src_ip, unicast_peer
multipass exec ka-node2 -- sudo bash -c "cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_script chk_nginx {
    script \"/usr/sbin/service nginx status\"
    interval 2
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    virtual_router_id 33
    state MASTER
    priority 100
    interface ens3
    advert_int 1
    accept
    unicast_src_ip $ip_node2
    unicast_peer {
    	$ip_node1
    }

    authentication {
        auth_type PASS
        auth_pass mypass
    }

    virtual_ipaddress {
        $ip_dot3
    }

    track_script {
        chk_nginx
    }
}
EOF"

# -------------------------------------------------------------------

echo
echo "### Restart keepalived to load the new configuration"

multipass exec ka-node1 -- sudo service keepalived start
multipass exec ka-node2 -- sudo service keepalived start

# -------------------------------------------------------------------

echo
echo "Keepalived is now configured to run high-availability nginx across two nodes. You can now test failover to see it in action."
echo
echo "You can access the web service at http://$ip_dot3"
echo "For example:"
echo "$ curl $ip_dot3"
curl $ip_dot3

echo
echo "You can test a failover by shutting down ka-node1:"
echo "$ multipass stop ka-node1"
echo "$ curl $ip_dot3"
echo
echo "Afterwards, restarting ka-node1 will move the virtual IP back:"
echo "$ multipass start ka-node1"
echo "(wait a couple of seconds)"
echo "$ curl $ip_dot3"

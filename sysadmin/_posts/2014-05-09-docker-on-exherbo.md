---
locale: en
layout: post

title: "Docker on Exherbo"
author: clementd
level: 4
banner: "/img/medias/docker-exherbo.png"
---

Because *reasons*, I've been playing a bit with Docker these last days.
Docker is a tool aimed at simplifying the use of containers (it uses LXC under the hood).
Containers are presented as a lightweight alternative to VMs, using process isolation instead of real virtualization.

<!--more-->

**Please note that Docker is not in 1.0 yet and therefore should not be used in production**


Since the kernel is shared between the host and the containers, some coupling is created between the host and the container OSes.
Since docker was more or less designed to run over AWS VMs, ubuntu used to be the only supported distro and is still the only officially supported distro.
There is also boot2docker which is a minimal distro designed to serve as a host.

For many reasons, I don't use ubuntu, I use a source-based distro called exherbo (try it, it's awesome).
Docker is packaged for exherbo, but the "out of the box" experience outside from ubuntu-land is a bit patchy.
Unfortunately, the docker documentation does not list the required kernel options.
The closest thing to an official list I've found is a gentoo ebuild and a script in the Docker Repo but both are very incomplete.

Fortunately, [W Trevor King](http://blog.tremily.us/) went over the documentation of the tools Docker uses (LXC, bridging, …) and made a list of needed options.

So, you'll need:

    CONFIG_CGROUP_DEVICE=y
    CONFIG_MEMCG=y
    CONFIG_USER_NS=y
    CONFIG_UIDGID_STRICT_TYPE_CHECKS=y #Gone in Linux 3.14
    CONFIG_MM_OWNER=y
    CONFIG_NETFILTER_ADVANCED=y
    CONFIG_BRIDGE_NETFILTER=y
    CONFIG_NF_NAT=m
    CONFIG_NF_NAT_NEEDED=y
    CONFIG_NF_NAT_FTP=m
    CONFIG_NF_NAT_IRC=m
    CONFIG_NF_NAT_SIP=m
    CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
    CONFIG_NF_NAT_IPV4=m
    CONFIG_IP_NF_TARGET_MASQUERADE=m
    CONFIG_NF_NAT_IPV6=m
    CONFIG_IP6_NF_TARGET_MASQUERADE=m
    CONFIG_STP=m CONFIG_BRIDGE=m
    CONFIG_BRIDGE_IGMP_SNOOPING=y
    CONFIG_VLAN_8021Q=m
    CONFIG_LLC=m
    CONFIG_DM_BUFIO=m
    CONFIG_DM_BIO_PRISON=m
    CONFIG_DM_PERSISTENT_DATA=m
    CONFIG_DM_THIN_PROVISIONING=m
    CONFIG_MACVLAN=m
    CONFIG_VETH=m
    CONFIG_DEVPTS_MULTIPLE_INSTANCES=y


To get docker running.
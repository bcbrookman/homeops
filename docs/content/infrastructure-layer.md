# Infrastructure Layer

This layer provides the basic networking, storage, and compute resources used by the [Platform Layer](https://bcbrookman.github.io/homeops/platform-layer/). It includes physical hardware, hypervisors, and other infrastructure components.

![infrastructure layer diagram](assets/homeops-layers-if.svg)

## Compute

Compute resources are provided using the following hardware:

|Qty.|Model|CPU|Memory|Storage|Usage|
|----|-----|---|------|-------|-----|
|3|Lenovo ThinkCentre M910q|Intel i7-7700T|16GB|512GB|Proxmox VE|

## Storage

All bare-metal and VM workloads run off directly attached disks. For other bulk data storage needs, a [Synology DiskStation DS920+](https://www.synology.com/en-us/products/DS920+) NAS is used. Currently the following disks are installed in a Synology Hybrid Raid (SHR) array, providing about [12TB of available storage](https://www.synology.com/en-us/support/RAID_calculator?hdds=6%20TB|6%20TB|3%20TB|3%20TB).

|Qty.|Series|Model #|Interface|Capacity|
|----|------|-------|---------|--------|
|2|Seagate Iron Wolf|ST6000V001-2BB186|SATA|6TB|
|1|Seagate Barracuda|ST3000DM001-1CH166|SATA|3TB|
|1|Western Digital Green|WD30EZRX-00DC0B0|SATA|3TB|

### Backups

Where possible, encrypted backups are saved to the NAS using [Duplicati](https://www.duplicati.com/) installed on each host. The NAS then syncs the backups to a cloud storage provider.

This satisfies the 3-2-1 rule since there are always 3 copies of the data: one on the source, one on the NAS, and another in the cloud. It is always on at least 2 different media, and 1 copy is always offsite.

## Networking

Logically, the network is divided into VLANs by usage.

- The DMZ VLAN
- The Inside VLAN
- The Services VLAN
- The IoT VLAN
- The Guest VLAN

![logical network topology diagram](assets/homeops-logical-network-topology.svg)

As illustrated in the logical topology diagram above, traffic to and from each VLAN is policed by firewalls. In general, the firewall rules restrict access according to the following table.

|Source|Allowed Destinations|
|------|--------------------|
|Inside|Internet, DMZ, Services*, IoT*|
|Services|Internet, DMZ, IoT*|
|IoT|Internet, DMZ, Services*|
|Guest|Internet, DMZ|
|DMZ|Internet, Services*|

*As needed, for specific hosts/services only

Physically, the network topology is fairly small using only a handful of desktop switches, access points, and an internet firewall.

|Qty.|Model|CPU|Memory|Storage|Usage|
|----|-----|---|------|-------|-----|
|1|Mikrotik hEX RB750Gr3|MMIPS MT7621A|256MB|16MB|WAN Router|
|2|HP T740 Thin Client|AMD Ryzen V1756B|32GB|500GB|Firewall|
|1|UniFi FlexHD|---|---|---|Wi-Fi|
|1|UniFi AP U6 Extender|---|---|---|Wi-Fi|
|3|UniFi USW-8|---|---|---|Switching|

The network is designed with redundant network paths wherever possible, but much of the service redundancy is handled at the application level.

![physical network topology diagram](assets/homeops-physical-network-topology.svg)

The WAN router is only used to allow for redundant [pfSense](https://www.pfsense.org/) firewalls with only one dynamic public IP address. Outbound traffic is source NATed to the current WAN interface address, and all inbound traffic is destination NATed to the floating WAN CARP virtual address. In many consumer routers, this would be similar to setting the WAN CARP virtual address as the DMZ host.

## WLAN

The WLAN is a straightforward deployment with 2 SSIDs. One SSID uses WPA2-EAP authentication with PEAP-MSCHAPv2 (for now), while the other uses standard WPA2-PSK authentication to support IoT and guest devices.

For both SSIDs, VLANs are dynamically assigned to clients using FreeRADIUS (currently on [pfSense](https://www.pfsense.org/)) based on either the authenticating user account, or by client MAC address if PSK authentication was used. In the case of PSK authentication, if the client MAC address is unknown, they are placed in the Guest VLAN as a default.

## Power

Power to all equipment is provided by the following two UPSes.

|Qty.|Model|Volt-ampere|Watts|
|----|-----|-----------|-----|
|1|CyberPower CP1500PFCLCD|1500VA|1000W|
|1|CyberPower OR700LCDRM1U|700VA|400W|

To help prevent a single UPS failure from becoming a single point of failure, clustered and highly available components are always powered by different UPSes. However, since many clusters (including [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview) and [Kubernetes](https://kubernetes.io)) require an odd number of nodes to maintain quorum, a single UPS failure might still be problematic depending on which UPS fails. Both UPSes are also plugged into the same electrical circuit so a breaker trip or other problem would cause power loss to both UPSes.

These problems are currently accepted as compromises for using small form-factor, low-power, consumer hardware which often don't have redundant power supplies or NICs.

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

As illustrated in the logical topology diagram above, traffic to and from each VLAN is policed by a firewall. In general, the firewall rules restrict access according to the following table.

|Source|Allowed Destinations|
|------|--------------------|
|Inside|Internet, DMZ, Services*, IoT*|
|Services|Internet, DMZ, IoT*|
|IoT|Internet, DMZ, Services*|
|Guest|Internet, DMZ|
|DMZ|Internet, Services*|

*As needed, for specific hosts/services only

Physically, the network topology is fairly simple with only a handful of desktop switches, access points, and an internet firewall.

|Qty.|Model|CPU|Memory|Storage|Usage|
|----|-----|---|------|-------|-----|
|1|HP T740 Thin Client|AMD Ryzen V1756B|32GB|500GB|Firewall|
|1|UniFi FlexHD|---|---|---|Wi-Fi|
|1|UniFi AP U6 Extender|---|---|---|Wi-Fi|
|1|UniFi USW-Flex-Mini|---|---|---|Switching|
|3|UniFi USW-8|---|---|---|Switching|

![physical network topology diagram](assets/homeops-physical-network-topology.svg)

To help conserve power and reduce overall complexity, only a single firewall is used in this topology. In the rare event that this firewall should fail, I also maintain a spare (but less capable) router which can quickly be installed in its place to restore connectivity.

SW04 is a tiny Unifi Flex Mini switch used only to provide switching for FW01 which does not have switching hardware. It is powered primarily by a USB port on FW01, with redundant power also provided via PoE from SW02.

SW01 is configured as the primary spanning-tree root bridge and SW02 as the secondary. The dashed lines in the diagram represent links that will be blocked by spanning-tree when SW01 is root. This configuration was done to help protect the east-west traffic between servers by not traversing the link between SW01 and SW04 which aggregates internet-bound traffic.

The end devices shown have also been strategically placed to help protect east-west traffic between the servers. For example, AP01 is connected via SW01 so that the mostly internet-bound traffic from wireless devices will not traverse the same links between the servers.

## WLAN

The WLAN is a straightforward deployment with 2 SSIDs. One SSID uses WPA2-EAP authentication with PEAP-MSCHAPv2 (for now), while the other uses standard WPA2-PSK authentication to support IoT and guest devices.

For both SSIDs, VLANs are dynamically assigned to clients using FreeRADIUS (currently on [pfSense](https://www.pfsense.org/)) based on either the authenticating user account, or by client MAC address if PSK authentication was used. In the case of PSK authentication, if the client MAC address is unknown, they are placed in the Guest VLAN as a default.

## Power

Power to all equipment is provided by the following two UPSes.

|Qty.|Model|Volt-ampere|Watts|
|----|-----|-----------|-----|
|1|CyberPower CP1500PFCLCD|1500VA|1000W|

These problems are currently accepted as compromises for using small form-factor, low-power, consumer hardware which often don't have redundant power supplies or NICs.

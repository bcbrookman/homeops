# Naming Conventions

## Host DNS names

For my small home network, I try to keep things simple and avoid using a super rigid highly encoded naming scheme. That said, I do have a convention I follow to help keep things manageable.

```
<functional-name>-<form-factor><random-int>[-iface].<site>.<domain>.
```

Where:

- `functional-name` is a minimumn 3 character, non-delimited string representing the primary function of the host.
    - Functional names should follow these guidelines:
        - Similar types of hosts should be named consistently (e.g. wanfw, lansw).
        - Encode context when possible, but keep it somewhat readable.
        - Don't use indexes, that's what the next fields are for (i.e. don't add 01, 02, etc.)
        - Don't use dashes or other delimitting characters.
        - Nicknames are okay, but they should be informative (e.g. sodapop for a Pop_OS! host)
- `form-factor` is a 2 character code for the host's form-factor
    - Form factor codes currently include:
        - `dt` = Desktop PC
        - `lt` = Laptop/notebook PC
        - `rp` = Raspberry Pi or similar SBC
        - `lc` = lxc container
        - `md` = Mobile device (phone, tablet, etc.)
        - `nw` = Network device
        - `sv` = Server hardware (bare-metal)
        - `vm` = Virtual machine
        - `st` = Smart thing (IoT, TV, speaker, etc.)
        - `ot` = Other devices
- `random-int` is a randomly generated 4 digit integer combined with `form-factor` to create a unique identifier
- `iface` is an optional interface name for cases where creating hostnames per interface is useful.
- <a id="site-definition"></a>`site` is a string indicating the location or cloud the host is in.
    - Sites identify where the device or service is physically located.
    - For portability and privacy reasons, they do not include geographic details.
    - Site zones are ***ONLY*** used internally and ***NEVER*** externally.
    - Sites currently include:
        - `home` = My primary home
        - `<cloud>` = Cloud provider where `cloud` is the provider's name (no region/zone)
        - `<initials>h` = Family members' home where `initials` are the owner's initials
- `domain` is my domain name

### Convenience aliases

For convenience, more friendly alias records can also be created as needed. For example, the host `wanfw-dt2923.home.example.com.` might have the alias `firewall.home.example.com.` created for it.

Aliases can also help decouple the device's hostname from its role. Replacing `wanfw-dt2923` which has the `firewall` alias with a new host, for example, could be done gradually by first staging the new host, then migrating the alias to it, and finally removing the old host.

### Examples

- lanap-nw2910.home.example.com.
- wanfw-dt2923.home.example.com.
- k8scp-dt9048.home.example.com.
- k8swk-sb5819.home.example.com.
- sodapop-lt2919.home.example.com.
- briphone-md1929.home.example.com.
- sodapop.home.example.com. --> sodapop-lt2919.home.example.com.
- firewall.home.example.com. --> wanfw-dt2923.home.example.com.

## Service DNS names

```
<service-name>[.group][.site].<domain>.
```

Where:

- `service-name` is a user-friendly service name
- `group` is a logical grouping of services (optional)
    - Currently, groups are only used for targets of simpler service name aliases
    - group zones are ***ONLY*** used internally and ***NEVER*** externally
    - groups currently include:
        - `<cluster-name>` = Services exposed by a specific cluster or device
- `site` is the site the service is located at (optional)
    - Same as the [site definition](#site-definition) for Host DNS names above
- `domain` is self explanatory

### Examples

- myservice.example.com. --> myservice.talos3415.home.example.com.
- myservice.talos3415.example.com. --> myservice.talos3415.home.example.com.

## Cluster names

Clusters and similar resources should be named without delimiting characters such as dashes or underscores, following the format below. This convention helps ensure uniqueness, and allows them to be more easily used in hostnames and other configurations.

```
<type>[env]<random-int>
```

Where:

- `function` is the type or primary function of the cluster/resource
- `env` is an optional environment (if dedicated and not production)
- `random-int` is a unique randomly generated 4 digit integer

### Examples

- talos3415
- pgsql2151

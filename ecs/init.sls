{% from "ecs/map.jinja" import ecs with context -%}

{% for dir in ecs.agent_dirs %}
{{ dir }}:
  file.directory

{%- endfor %}


net.ipv4.conf.all.route_localnet:
    sysctl.present:
      - value: 1

iptables-dnat:
  iptables.append:
    - table: nat
    - rule: "-p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679"
    - save: True

iptables-redirect:
  iptables.append:
    - table: nat
    - rule: "-d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679"
    - save: True

{{ ecs.config_file }}:
  file.managed:
    - source: salt://ecs/templates/ecs.config.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/nfsdata:
  mount.mounted:
    - device: nfs-01:/data
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts:
      - soft
      - intr
      - rsize=1048576
      - wsize=1048576


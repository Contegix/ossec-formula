{% from "ossec/map.jinja" import ossec with context %}

include:
  - atomic

ossec-install:
  pkg.installed:
    - pkgs:
      - ossec-hids-agent
      - inotify-tools

ossec-conf:
  file.managed:
    - name: /var/ossec/etc/ossec.conf
    - source: salt://ossec/files/ossec.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - defaults:
        ossec: {"ip": {{ salt['pillar.get']('ossec:ip', '127.0.0.1') }}, "hostname": {{ salt['pillar.get']('ossec:hostname', 'localhost')}} }

ossec-keys:
  file.absent:
    - name: /var/ossec/etc/client.keys
    - onchanges:
      - file: /var/ossec/etc/ossec.conf
  cmd.run:
    - name: sleep 1 && /var/ossec/bin/agent-auth -m {{ salt['pillar.get']('ossec:ip', '127.0.0.1') }} -p 1515
    - unless: 'test -e /var/ossec/etc/client.keys'

ossec-start:
  service.running:
    - name: {{ ossec.service }}
    - enable: True
    - watch:
      - pkg: ossec-install
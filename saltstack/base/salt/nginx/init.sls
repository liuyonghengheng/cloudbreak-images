install_nginx:
  pkg.installed:
    - refresh: False
    - pkgs:
      - nginx

/etc/nginx:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - template: jinja
    - source: salt://{{ slspath }}/etc/nginx/nginx.conf

/etc/nginx/sites-enabled/ssl-template:
  file.managed:
    - name: /etc/nginx/sites-enabled/ssl-template
    - template: jinja
    - makedirs: True
    - source: salt://{{ slspath }}/etc/nginx/ssl.conf

enable_nginx:
  service.enabled:
    - name: nginx
    - require:
      - pkg: install_nginx

{% if pillar['OS'] != 'ubuntu18' and pillar['OS'] != 'ubuntu16' and  pillar['OS'] != 'debian9' %}

nginxRestart:
  file.line:
    - name: /usr/lib/systemd/system/nginx.service
    - mode: ensure
    - content: "Restart=always"
    - after: \[Service\]
    - backup: False

nginxRestartSec:
  file.line:
    - name: /usr/lib/systemd/system/nginx.service
    - mode: ensure
    - content: "RestartSec=3"
    - after: "Restart=always"
    - backup: False

{% else %}
nginxRestart:
  file.line:
    - name: /lib/systemd/system/nginx.service
    - mode: ensure
    - content: "Restart=always"
    - after: \[Service\]
    - backup: False

nginxRestartSec:
  file.line:
    - name: /lib/systemd/system/nginx.service
    - mode: ensure
    - content: "RestartSec=3"
    - after: "Restart=always"
    - backup: False
{% endif %}

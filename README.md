Как пользоваться этим софтом?
Да просто! У нас должен быть рабочий openvpn сервер, и в его конфигурации должна быть строка к примеру:
```bash
management 0.0.0.0 5555
```
Тут важно:
  ip
  port

ip - это адресс на котором будет листаться management порт
port - это собственно сам порт на котором будет происходить обмен данными с нашим докер контейнером

В контейнер нам надо передать конфиг и заэкспоузать порт 80 который дальше можно проксировать (делать отдельный location или virtualhost).

Пример запуска:
```bash
docker run -d -v "$(pwd)/openvpn-monitor.cfg:/var/www/html/openvpn-monitor.cfg:rw" registry.pyhead.net/openvpn-status-base
```

Подробно описывать каждую опцию мне лениво. Читайте доку.

Для Ansible:
http://docs.ansible.com/ansible/docker_module.html

```ansible
- name: Start container
  docker:
    name: openvpn-status
    image: registry.pyhead.net/openvpn-status-base
    state: reloaded
    pull: always
    registry: registry.pyhead.net
    username: user*
    password: pass*
    ports:
      - 8081:80
    volumes:
      - "путь.относиткльно.корня.ansible.или.роли/плейбука/openvpn-monitor.cfg:/var/www/html/openvpn-monitor.cfg:rw"
```

Для nginx location:

В вашем домене надо добавить к примеру
```
        location /openvpn-status {
                proxy_pass       http://localhost:8081;
                rewrite ^/openvpn-status/(.*)$ /$1 break;
                proxy_set_header Host      $host;
                proxy_set_header X-Real-IP $remote_addr;
        }
```

либо описать целый virtualhost
```
server {
        listen 80;
        server_name ovpnstatus.pyhead.net;
        server_tokens off;
        access_log /var/log/nginx/ovpnstatus.access.log;
        location / {
	        proxy_set_header X-Real-IP $remote_addr
	        proxy_set_header Host $http_host;
	        proxy_pass http://127.0.0.1:8081;
	        break;
        }
}
```

Пример конфига
```
[OpenVPN-Monitor]
site=True name
#logo=./logo.png
#latitude=46.9397677
#longitude=31.9505492
maps=True
datetime_format=%d/%m/%Y %H:%M:%S

[True server]
host=IP/FQDN
port=5555
name=True OpenVPN Server

[ololo server]
host=IP/FQDN
port=5555
name=ololo OpenVPN Server
```

рабочий пример с location в nginx => http://www.pyhead.net/openvpn-status/

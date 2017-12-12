#cloud-config
---
coreos:
  units:
    - name: mongo.service
      command: start
      content: |
        [Unit]
        Description=Starts Mongo Service
        [Service]
        ExecStart=/usr/bin/docker run --name mongo mongo
        ExecStop=/usr/bin/docker stop mongo
        Restart=always
        RestartSec=10
        [Install]
        WantedBy=multi-user.target
    - name: nginx.service
      command: start
      content: |
        [Unit]
        Description=Starts Nginx Service
        Requires=app1.service
        Requires=app2.service
        [Service]
        ExecStart=/usr/bin/docker run -p 80:80 --name nginx --link app1:app1 --volumes-from app1:ro --link app2:app2 --volumes-from app2:ro lbracken/docker-example-nginx 
        ExecStop=/usr/bin/docker stop nginx
        Restart=always
        RestartSec=10
        [Install]
        WantedBy=multi-user.target
    - name: app1.service
      command: start
      content: |
        [Unit]
        Description=Starts App1 Service
        Requires=mongo.service
        [Service]
        ExecStart=/usr/bin/docker run -P --name app1 lbracken/docker-example-app1
        ExecStop=/usr/bin/docker stop app1
        Restart=always
        RestartSec=10
        [Install]
        WantedBy=multi-user.target
    - name: app2.service
      command: start
      content: |
        [Unit]
        Description=Starts App2 Service
        Requires=mongo.service
        [Service]
        ExecStart=/usr/bin/docker run -P --name app2 --link mongo:db lbracken/docker-example-app2
        ExecStop=/usr/bin/docker stop app2
        Restart=always
        RestartSec=10
        [Install]
        WantedBy=multi-user.target
    

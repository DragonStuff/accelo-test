Install required packages:
  pkg.installed:
    - pkgs:
      - curl
      - openssl
      - nginx
      - git
Configure Nginx config for web:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://files/nginx.conf
Install git:
  pkg.installed: 
    - name: git
Configure SSL:
  cmd.run:
    - name: |
        echo mypass | openssl genrsa -passout pass:mypass -des3 -out accelo.key 1024 -subj "/C=US/ST=Test/L=Test/O=Test/CN=localhost"
        openssl req -new -key accelo.key -passin pass:mypass -out accelo.csr -subj "/C=US/ST=Test/L=Test/O=Test/CN=localhost"
        cp accelo.key accelo.key.org
        openssl rsa -in accelo.key.org -passin pass:mypass -out accelo.key
        rm accelo.key.org
        openssl x509 -req -days 365 -in accelo.csr -passin pass:mypass -signkey accelo.key -out accelo.crt
        mkdir -p /etc/ssl/certs
        cp accelo.crt /etc/ssl/certs/
        mkdir -p  /etc/ssl/private
        cp accelo.key /etc/ssl/private/
Downloading repository files:
  git.latest:
    - name: https://bitbucket.org/mark_curtis/devops_test_project.git
    - rev: web
    - target: /var/www
Restart Nginx:
  cmd.run:
    - name: "/etc/init.d/nginx restart"
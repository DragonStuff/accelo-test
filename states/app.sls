Install required packages:
  pkg.installed:
    - pkgs:
      - curl
      - openssl
      - git
      - gcc 
      - gcc-c++
      - make
      - automake
      - autoconf
      - mysql
      - mysql-devel
Install Perl:
  pkg.installed:
    - pkgs:
      - perl
      - perl-core
      - perl-CPAN
      - perl-devel
Install Perl cpanmin:
  cmd.run:
    - name: "curl -L https://cpanmin.us | perl - --sudo App::cpanminus"
    - cwd: /home/ec2-user
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
    - rev: app
    - target: /home/ec2-user/app
Install nonclean dependency:
  cmd.run:
    - name: "sudo /usr/local/bin/cpanm HTTP::XSCookies@0.000007"
    - cwd: /home/ec2-user/
Install SSL dependency:
  cmd.run:
    - name: "sudo /usr/local/bin/cpanm IO::Socket::SSL"
    - cwd: /home/ec2-user/
Install required perl dependencies:
  cmd.run:
    - name: "sudo /usr/local/bin/cpanm --installdeps ."
    - cwd: /home/ec2-user/app
Set environment variables:
   environ.setenv:
     - name: required_db_environment_vars
     - value:
         DBHOST: replaceme
         USERNAME: test_project
         PASSWORD: Simple+test^Project!
     - update_minion: True
Run the application:
  cmd.run:
    - name: "/usr/local/bin/plackup -D -p 80 bin/app.psgi > output.log 2>&1 &"
    - cwd: /home/ec2-user/app
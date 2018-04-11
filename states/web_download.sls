Set environment variables:
   environ.setenv:
     - name: required_db_environment_vars
     - value:
         DBHOST: replaceifnecessary
         USERNAME: test_project
         PASSWORD: Simple+test^Project!
Run the application:
  cmd.run:
    - name: "/usr/local/bin/plackup -D -p 80 bin/app.psgi > output.log 2>&1 &"
    - cwd: /home/ec2-user/app
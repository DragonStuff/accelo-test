# accelo-test

HTML Documentation located inside docs/

There is a copy of the docs that is in Markdown for use on Github. I recommend getting the documentation and rendering it locally in your web browser, it looks significantly nicer.

Keep in mind, all documentation is cronological. I did not go back and make edits so you could see my train of thought. This would not be done for a real project, where documentation needs to be lean and clean.

## Running

Download a copy of this repository and `cd` to make it your working directory.

You need to do `pip install awscli`.

There is a venv environment if you need that, otherwise do: `pip install salt-ssh` on your machine.

Create a new key with the name accelo-prod inside AWS as per the documentation.

Place your key here with the name "accelo-prod.pem"

Now run `sh automate.sh`.

This will take some time. Get a coffee, biscuit and chill.

Keep in mind, this will take quite a while to do it's thing. Around 15 minutes for the app server deployment, and 10 minutes for the web server deployment. Get a coffee while you wait.

Please take care of the previous notes regarding the template alterations. I am using sed above to replace the values so that we can connect the dots. There's lots to improve on in future.

You can kill plack with `sudo salt-ssh -i "app" --raw "sudo pkill -f plackup"` You can start plack again with `sudo salt-ssh --verbose -i "app" state.apply web_download`

**MAKE SURE TO REPLACE THE DBHOST WITH THE ONE IN THE states/app.sls IF YOU DO THE ABOVE. You can also just copy lines 55-66 and put them in states/web_download if you wish and then run the command to start plack.**

Some other notes:

* Optimise script to make less calls.
* Enable SSL on App side.
* Add more failsafes.
* The database instance should definitely have a name in future.
* Don't upload venv, use requirements.txt. Yes, I know, but honestly too much time has been spent on this already ;)
* Update docs if this was real.
* **Enable termination protection. Just had to re-iterate that. It's important.**

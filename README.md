remote_shade_control_app
========================

Tiny web app (sinatra) to control shades (curtains, drapes) via hardware control.

Configure the file via the settings.yml:

    production:
        shades:
          - name: "Living Room"
            id: "living_room"
            shade_type: "SomfyShade"
            channel: "2"
            raise_up_time: 30 minutes before
            lower_down_time: 30 minutes after

Shades may have additional settings, see the specific shades libraries for details.

To run the test suite:

    ruby test/test.rb

To run the server:

    ruby run_app.rb

The settings file uses Chronic for parsing, so it understands all kinds of statements like: 

    1 hour before
    30 minutes after

To fully automate the app, the /auto URL should be "pinged" regularly.  Easiest is to set a crontab that will hit the URL every minute.  Add this to your /etc/crontab to run every minute:

    * *     * * *   root    curl http://localhost/auto

Screenshot:

![Remote Shade Control](http://f.cl.ly/items/0K3B0g462E0f0r2i221R/remote_shade_control.png "Remote Shade Control Screenshot")


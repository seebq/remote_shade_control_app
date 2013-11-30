remote_shade_control_app
========================

Tiny web app (sinatra) to control shades (curtains, drapes) via hardware control.

Configure the file via the settings.yml:

    production:
        shade_button_up: "./GPIO.sh 14"
        shade_button_stop: "./GPIO.sh 13"
        shade_button_down: "./GPIO.sh 12"
        raise_up_time: 10 minutes before
        lower_down_time: 55 minutes after

To run the test suite:

    ruby test/test.rb

To run the server:

    ruby run_app.rb

The settings file uses Chronic for parsing, so it understands all kinds of statements like: 

    1 hour before
    30 minutes after

Screenshot:

![Remote Shade Control](http://f.cl.ly/items/0K3B0g462E0f0r2i221R/remote_shade_control.png "Remote Shade Control Screenshot")


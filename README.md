Easy fake network
=============

This is a easy way to create fake and running network.
Follow these steps to setup.

* Open config.yml and insert either your username and password or your session_id
* Use `bundle install`
* Run `ruby network.rb`

The program will create a network with some states. The network name will be the one you specified in the config.yml plus a random string.

After that the program start to run and it will update the data at almost random time.</br>
Use CTRL+C to stop the program to run.

Use `ruby network.rb create` to only create a network.</br>
Use `ruby network.rb run` to only run a network.</br>
Use `ruby network.rb delete` to delete all the network created with this string</br>

Easy fake network
=============

This is a easy way to create fake and running network.
Follow these steps to setup.

* Open config.yml and insert either your username and password or your session_id
* Use `bundle install`
* Run `bundle exec ruby network.rb`

The program will create a network with some states. The network name will be the one you specified in the config.yml plus a random string.

After that, the program starts to run and it will update the data at almost random time.</br>
Use CTRL+C to stop the program.

Use `bundle exec ruby network.rb create` to only create a network.  
Use `bundle exec ruby network.rb run` to only run a network.  
Use `bundle exec ruby network.rb delete` to delete all the network created with this string.  
Use `bundle exec ruby network.rb listen` to listen for coming events.
Use `bundle exec ruby network.rb contine_post` to continue to post the network (you must specify the network_id).

Configuration file
----------------------

To configure a file create a `config.yml` file. The content will be merged with the one of `default.yml` file.  

```yaml
host: "https://wappsto.com"
verbose: true
old_endpoint: true

authentication:
  session_id:
  username:
  password:

network:
  name: "Special network"
  use_structure: false
  number: 1
device:
  number:
status:
  number: 0
value:
  number:
  type: "number"
  permission: ["r", "w", "rw"]
state:
  rate: 0.1

iot:
  active: false
  host: wappsto.com
  port: 42005
  close_connection: false
```

`host`: host of the website  
`verbose`: true if you want to have more information  
`old_endpoint`: true if you want to use old backend (without 2.0)  
`authentication`: specify either a valid session_id or your credentials  
`network`: specify the name of the network, if you want to structured network (from `structure.json`, and how many network you want to create)  
`device`: specify how many devices you want to create  
`value`: specify the permission, how many values you wish and the type (if not specified it will be random)  
`state`: specify in rate how often the control states should be updated  
`iot`: specify if you want to use an active endpoint with host and port. You can specify if you want to close the connection  

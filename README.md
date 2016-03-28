# authsome
authsome is some simple application-glue that provides a consistent (and easy) way of using multiple oauth services together in the same application.

## Example
There is a Sinatra example that should generate a fake dashboard to link against dropbox, instagram and linkedin. The setup for this is kept in `environment_dev.json`, which is a dotcloud-ism (this is now Docker Cloud). The keys for the services are located in environment variables, which is what `environment_dev.json` specifies.

## Todo

* Add more services (always more services!)
* Make the Sinatra demo multi-user
* Salt/hash/encrypt or otherwise make the acquired access tokens more secure
* Add tests
* Convert to a gem

# License & Copyright
The code is Copyright 2012-2016 Pieter Sartain, and released under the MIT license. See license.txt for details.

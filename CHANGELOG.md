# 0.0.19 / Unreleased

* Adds authorization to the datastore

# 0.0.18

* Fixes small bug in batch UUID retrieval

# 0.0.17

* Fixes Ruby version on Heroku

# 0.0.16

* Updates depencies

# 0.0.15

* Updates json

# 0.0.14

* Adds endpoint for batch retrieval of data sets

# 0.0.13

* Improve Newrelic instrumenting

# 0.0.12

* Adds Newrelic monitoring and ping middleware

# 0.0.11

* Moves to a fixed grape gem hosted on our own gem server instead of a git link

# 0.0.10

* Refactors API and dismisses the public/private scopes completely

# 0.0.9

* Relaxes dependency on auth-client

# 0.0.8

* ``OPTIONS`` requests don't need to be authenticated anymore

# 0.0.7

* Secures all requests with OAuth2

# 0.0.6

* Adds thin to the main bundle to run on heroku

# 0.0.5

* Makes it possible to change parts of data sets
* Hardens the API for the use behind Rack::Lint
* A lot of ``metaserver`` related improvements

# 0.0.4

* Fixes bug that prevented the server from booting

# 0.0.3

* Makes it possible to create data sets without specifying a UUID. A new
  one will be created for you.
* Adds the UUID of a data set to each response.

# 0.0.2

The start.

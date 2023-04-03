# DramaConnect API

API to store the Drama Review To Your Friends

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/dramas/`: returns all dramas IDs
- GET `api/v1/dramas/{ID}`: returns details about a single dramas with given ID
- POST `api/v1/dramas/`: creates a new dramas

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
puma
```

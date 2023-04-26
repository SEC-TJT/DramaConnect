# DramaConnect API

API to store the Drama Review To Your Friends

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/dramaList`: returns all drama list
- GET `api/v1/dramaList/{dramaList_id}`: returns details about a single drama list with given ID
- POST `api/v1/api/v1/dramaList`: creates a new drama list
- GET `api/v1/dramaList/{dramaList_id}/drama/{drama_id}`: returns details about a all the dramas in a given drama list wiht id 
- POST `api/v1/dramaList/{dramaList_id}/drama`: create a new drama to the drama list with given ID


## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Initialize Database
```shell
rake db:migrate

# for testing
RACK_ENV=test rake db:migrate    
```

## Test

Run the test script:

```shell
rake spec
```

## Execute

Run this API using:

```shell
puma
```

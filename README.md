# DramaConnect API

API to store the Drama Review To Your Friends

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET  `api/v1/accounts/[username]`: Get account details
- POST  `api/v1/accounts`: Create a new account
- GET `api/v1/dramaList`: Returns all drama list
- POST `api/v1/dramaList`: Create a new drama list
- GET `api/v1/dramaList/[dramaList_id]`: Returns details about a single drama list with given ID
- GET `api/v1/dramaList/[dramaList_id]/dramas`: Get list of dramas for drama list
- POST `api/v1/dramaList/[dramaList_id]/dramas`: Create a new drama to the drama list
- GET `api/v1/dramaList/[dramaList_id]/dramas/[drama_id]`: Returns details about a all the dramas in a given drama list wiht id 

## Install

Install this API by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate   
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug

Add fake data to the development database to work on this project:

```shell
rake db:seed
```

## Execute

Launch the API using:

```shell
rake run:dev
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release?
```


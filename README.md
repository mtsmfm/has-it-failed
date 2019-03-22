# Has it failed

Demo application to use public dataset `rails-travis-result.rails_travis_result.jobs`.

https://has-it-failed.herokuapp.com

For more information about this dataset, read https://github.com/mtsmfm/rails-ci-result-importer

## How to develop

### Requirements

- Docker
- Docker Compose

### Steps

```
$ docker-compose build
$ docker-compose run web bin/rails db:setup
$ touch app.env
$ $EDITOR app.env
```

### Env vars

- BIGQUERY_PROJECT: Project name to run SQL.
- BIGQUERY_CREDENTIALS: Bigquery creatential to run SQL. Set JSON content.

### Import data

```
$ docker-compose run web bin/rails r 'ImportFailedJobsJob.perform_now(from: Time.zone.parse("2019-02-01"), to: Time.zone.parse("2019-03-01"))'
```

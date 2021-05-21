# README

## Duplicate events quickly

```
insert into user_events(user_id, event_type, payload, created_at, updated_at) SELECT user_id, event_type, payload, created_at, updated_at
FROM "user_events"
where id > 1;
```

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

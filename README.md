# Protect

Protect provides searchable encryption for your ActiveRecord models.

With Protect you never need trade security for queryability - you can have both!

## Database support

Protect is compatible with the following databases:

* Postgres (self-hosted / cloud-hosted, e.g. Amazon RDS)
* MySQL (planned)
* MS SQL (planned)
* CockroachDB (planned)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "protect"
```

## Preparing your database

The first thing to do is install the Protect custom types into your database.

This is achieved by creating a new Rails migration the usual way, and adding the following code:

```ruby
class AddProtectRBSupport < ActiveRecord::Migration[7.0]
  def up
    Protect::DatabaseExtensionTypes.install
  end

  def down
    Protect::DatabaseExtensionTypes.remove
  end
end
```


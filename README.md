# ProtectRB 

ProtectRB provides searchable encryption for your ActiveRecord models.

With ProtectRB you never need trade security for queryability - you can have both!

## Database support

ProtectRB is compatible with the following databases:

* Postgres (self-hosted / cloud-hosted, e.g. Amazon RDS)
* MySQL (planned)
* MS SQL (planned)
* CockroachDB (planned)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "protect_rb"
```

## Preparing your database

The first thing to do is install the ProtectRB custom types into your database.

This is achieved by creating a new Rails migration the usual way, and adding the following code:

```ruby
class AddProtectRBSupport < ActiveRecord::Migration[7.0]
  def up
    ProtectRB::DatabaseExtensionTypes.install
  end

  def down
    ProtectRB::DatabaseExtensionTypes.remove
  end
end
```


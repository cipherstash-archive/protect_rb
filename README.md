# Protect

Protect provides searchable encryption for your ActiveRecord models.

With Protect you never need trade security for queryability - you can have both!

## Database support

Protect is compatible with the following databases:

- Postgres (self-hosted / cloud-hosted, e.g. Amazon RDS)
- MySQL (planned)
- MS SQL (planned)
- CockroachDB (planned)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "protect"
```

Run:

```bash
bundle install
```

## Preparing your database

**1. Install the Protect custom types:**

The first thing to do is install the Protect custom types into your database.

This is achieved by creating a new Rails migration the usual way, and adding the following code:

```ruby
class AddProtectDatabaseExtensions < ActiveRecord::Migration[7.0]
  def up
    Protect::DatabaseExtensions.install
  end

  def down
    Protect::DatabaseExtensions.remove
  end
end
```

This migration adds in the custom type `ore_64_8_v1`.

**2. Migration to add columns for encrypted data:**

For each field you are encrypting, 2 columns need to be added.

One to hold the encrypted source data.

One to hold the encrypted queryable data.

Field names appended with `_ciphertext` hold the source encrypted data.

Field names appended with `_secure_search` hold the encrypted queryable data.

For a plaintext field named `email`, a migration to add in the encrypted columns would look like this:

```ruby
class AddEncryptedFields < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_ciphertext, :text
    add_column :users, :email_secure_search, :ore_64_8_v1
  end
end
```

Note the custom type `ore_64_8_v1` we installed in the previous step is used on the `_secure_search` column.

## Encrypt plaintext data:

You are now ready to encrypt your existing plaintext data into the encrypted columns added in the previous step.

**1. Update the model:**

For each field that your are encrypting, update your model with `secure_search` followed by the field.

```ruby
class User < ApplicationRecord
  secure_search :email
end
```

**2. Run Rake task:**

The encrypt Rake task will encrypt your plaintext data into the 2 columns added in the previous step.

The existing plaintext field remains as is for now.

Provide the model that you are encrypting to the Rake task.

Using bash:

```bash
rake protect:encrypt[User]
```

Using zsh:

```bash
rake protect:encrypt\[User\]
```

**3. Update model:**

After the Rake task has completed, update the model to ignore the plaintext field.

```ruby
class User < ApplicationRecord
  secure_search :email

  # remove this line after dropping email column
  self.ignored_columns = ["email"]
end
```

**4. Drop plaintext column:**

Once satisfied that everything is working, create a migration to drop the plaintext column.

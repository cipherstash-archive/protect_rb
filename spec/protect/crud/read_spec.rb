RSpec.describe CipherStash::Protect::Model::CRUD do
  describe "Read secure_search" do
    before(:each) do
      CrudTesting.create!([
        {
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2020,9,14),
          age: 72,
          verified: true,
          latitude: 125.634496,
          email: "steve.zissou@belafonte.com"
        },
        {
          dob: Date.new(1947,9,22),
          last_login: DateTime.new(2022,10,12),
          age: 75,
          verified: false,
          latitude: 113.634496,
          email: "kingsley.zissou@belafonte.com"
        },
        {
          dob: Date.new(1967,9,27),
          last_login: DateTime.new(2022,7,1),
          age: 55,
          verified: false,
          latitude: 109.634496,
          email: "royal@tenenbaum.com"
        },
        {
          dob: Date.new(1993,3,11),
          last_login: DateTime.new(2022,8,7),
          age: 29,
          verified: true,
          latitude: 115.634496,
          email: "etheline@tenenbaum.com"
        },
      ])
    end

    describe "equality queries" do
      context "when using a integer type" do
        it "returns records using where" do
          user_via_integer = CrudTesting.where(age: 72)

          expect(user_via_integer.length).to eq(1)
          expect(user_via_integer.first.age).to eq(72)
        end

        it "returns records using find by" do
          user_via_integer = CrudTesting.find_by(age: 72)

          expect(user_via_integer).to_not be(nil)
          expect(user_via_integer.age).to eq(72)
        end

        it "returns records using dynamic finders" do
          user_via_integer = CrudTesting.find_by_age(72)

          expect(user_via_integer).to_not be(nil)
          expect(user_via_integer.age).to eq(72)
        end
      end

      context "when using a boolean type" do
        it "returns records using where" do
          user_via_boolean = CrudTesting.where(verified: true)

          expect(user_via_boolean.length).to eq(2)
          expect(user_via_boolean.first.verified).to eq(true)
          expect(user_via_boolean.second.verified).to eq(true)
        end

        it "returns records using find by" do
          user_via_boolean = CrudTesting.find_by(verified: true)

          expect(user_via_boolean).to_not be(nil)
          expect(user_via_boolean.verified).to eq(true)
        end

        it "returns records using dynamic finders" do
          user_via_boolean = CrudTesting.find_by_verified(true)

          expect(user_via_boolean).to_not be(nil)
          expect(user_via_boolean.verified).to eq(true)
        end
      end

      context "when using a date type" do
        it "returns records using where" do
          user_via_date = CrudTesting.where(dob: Date.new(1967,9,27))

          expect(user_via_date.length).to eq(1)
          expect(user_via_date.first.dob).to eq(Date.new(1967,9,27))
        end

        it "returns records using find_by" do
          user_via_date = CrudTesting.find_by(dob: Date.new(1967,9,27))

          expect(user_via_date).to_not be(nil)
          expect(user_via_date.dob).to eq(Date.new(1967,9,27))
        end

        it "returns records using dynamic finders" do
          user_via_date = CrudTesting.find_by_dob(Date.new(1967,9,27))

          expect(user_via_date).to_not be(nil)
          expect(user_via_date.dob).to eq(Date.new(1967,9,27))
        end
      end

      context "when using a datetime type" do
        it "returns records using where" do
          user_via_datetime = CrudTesting.where(last_login: DateTime.new(2022,8,7))

          expect(user_via_datetime.length).to eq(1)
          expect(user_via_datetime.first.last_login).to eq(DateTime.new(2022,8,7))
        end

        it "returns records using find by" do
          user_via_datetime = CrudTesting.find_by(
            last_login: DateTime.new(2022,8,7)
          )

          expect(user_via_datetime).to_not be(nil)
          expect(user_via_datetime.last_login).to eq(DateTime.new(2022,8,7))
        end

        it "returns records using dynamic finders" do
          user_via_datetime = CrudTesting.find_by_last_login(
            DateTime.new(2022,8,7)
          )

          expect(user_via_datetime).to_not be(nil)
          expect(user_via_datetime.last_login).to eq(DateTime.new(2022,8,7))
        end
      end

      context "when using a float type" do
        it "returns records using where" do
          user_via_float = CrudTesting.where(latitude: 109.634496)

          expect(user_via_float.length).to eq(1)
          expect(user_via_float.first.latitude).to eq(109.634496)
        end

        it "returns records using find by" do
          user_via_float = CrudTesting.find_by(latitude: 109.634496)

          expect(user_via_float).to_not be(nil)
          expect(user_via_float.latitude).to eq(109.634496)
        end

        it "returns records using dynamic finders" do
          user_via_float = CrudTesting.find_by_latitude(109.634496)

          expect(user_via_float).to_not be(nil)
          expect(user_via_float.latitude).to eq(109.634496)
        end
      end

      context "when using a string type" do
        it "returns records using where" do
          user_via_string = CrudTesting.where(email: "etheline@tenenbaum.com")

          expect(user_via_string.length).to eq(1)
          expect(user_via_string.first.email).to eq("etheline@tenenbaum.com")
        end

        it "returns records using find by" do
          user_via_string = CrudTesting.find_by(email: "etheline@tenenbaum.com")

          expect(user_via_string).to_not be(nil)
          expect(user_via_string.email).to eq("etheline@tenenbaum.com")
        end

        it "returns records using dynamic finders" do
          user_via_string = CrudTesting.find_by_email("etheline@tenenbaum.com")

          expect(user_via_string).to_not be(nil)
          expect(user_via_string.email).to eq("etheline@tenenbaum.com")
        end
      end

      context "when querying nil" do
        it "does not return a record" do
          CrudTesting.create(
            dob: Date.new(1950,9,21),
            last_login: DateTime.new(2022,10,14),
            age: nil,
            verified: true,
            latitude: 150.634496,
            email: "test@email.com"
          )

          returned_user = CrudTesting.where(
            age: 70
          )
          expect(returned_user.length).to eq(0)
        end
      end
    end

    describe "range queries" do
      context "when using an integer type" do
        it "returns records using gt" do
          user_via_integer = CrudTesting.where.not(
            age: ..72
          )

          expect(user_via_integer.length).to eq(1)
        end

        it "returns records using gte" do
          user_via_integer = CrudTesting.where(
            age: 72..
          )

          expect(user_via_integer.length).to eq(2)
        end

        it "returns records using lt" do
          user_via_integer = CrudTesting.where(
            age: ...72
          )

          expect(user_via_integer.length).to eq(2)
        end

        it "returns records using lte" do
          user_via_integer = CrudTesting.where(
            age: ..72
          )

          expect(user_via_integer.length).to eq(3)
        end
      end

      context "when using a date type" do
        it "returns records using gt" do
          user_via_date = CrudTesting.where.not(
            dob: ..Date.new(1950,9,21)
          )

          expect(user_via_date.length).to eq(2)
        end

        it "returns records using gte" do
          user_via_date = CrudTesting.where(
            dob: Date.new(1950,9,21)..
          )

          expect(user_via_date.length).to eq(3)
        end

        it "returns records using lt" do
          user_via_date = CrudTesting.where(
            dob: ...Date.new(1950,9,21)
          )

          expect(user_via_date.length).to eq(1)
        end

        it "returns records using lte" do
          user_via_date = CrudTesting.where(
            dob: ..Date.new(1950,9,21)
          )

          expect(user_via_date.length).to eq(2)
        end
      end

      context "when using a datetime type" do
        it "returns records using gt" do
          user_via_datetime = CrudTesting.where.not(
            last_login: ..DateTime.new(2022,7,1)
          )

          expect(user_via_datetime.length).to eq(2)
        end

        it "returns records using gte" do
          user_via_datetime = CrudTesting.where(
            last_login: DateTime.new(2022,7,1)..
          )

          expect(user_via_datetime.length).to eq(3)
        end

        it "returns records using lt" do
          user_via_datetime = CrudTesting.where(
            last_login: ...DateTime.new(2022,7,1)
          )

          expect(user_via_datetime.length).to eq(1)
        end

        it "returns records using lte" do
          user_via_datetime = CrudTesting.where(
            last_login: ..DateTime.new(2022,7,1)
          )

          expect(user_via_datetime.length).to eq(2)
        end
      end

      context "when using a float type" do
        it "returns records using gt" do
          user_via_float = CrudTesting.where.not(
            latitude: ..109.634496
          )

          expect(user_via_float.length).to eq(3)
        end

        it "returns records using gte" do
          user_via_float = CrudTesting.where(
            latitude: 109.634496..
          )

          expect(user_via_float.length).to eq(4)
        end

        it "returns records using lt" do
          user_via_float = CrudTesting.where(
            latitude: ...109.634496
          )

          expect(user_via_float.length).to eq(0)
        end

        it "returns records using lte" do
          user_via_float = CrudTesting.where(
            latitude: ..109.634496
          )

          expect(user_via_float.length).to eq(1)
        end
      end

      context "when using a boolean type" do
        it "returns records using gt" do
          user_via_boolean = CrudTesting.where.not(
            verified: ..true
          )

          expect(user_via_boolean.length).to eq(0)
        end

        it "returns records using gte" do
          user_via_boolean = CrudTesting.where(
            verified: true..
          )

          expect(user_via_boolean.length).to eq(2)
        end

        it "returns records using lt" do
          user_via_boolean = CrudTesting.where(
            verified: ...true
          )

          expect(user_via_boolean.length).to eq(2)
        end

        it "returns records using lte" do
          user_via_boolean = CrudTesting.where(
            verified: ..true
          )

          expect(user_via_boolean.length).to eq(4)
        end
      end
    end

    describe "#order" do
      context "when using an integer type" do
        it "returns records using order asc" do
          user_via_integer = CrudTesting.order(age: :asc).first

          expect(user_via_integer).to_not be(nil)
          expect(user_via_integer.age).to eq(29)
        end

        it "returns records using order desc" do
          user_via_integer = CrudTesting.order(age: :desc).first

          expect(user_via_integer).to_not be(nil)
          expect(user_via_integer.age).to eq(75)
        end
      end

      context "when using a boolean type" do
        it "returns records using order asc" do
          user_via_float = CrudTesting.order(verified: :asc).first

          expect(user_via_float).to_not be(nil)
          expect(user_via_float.verified).to eq(false)
        end

        it "returns records using order desc" do
          user_via_float = CrudTesting.order(verified: :desc).first

          expect(user_via_float).to_not be(nil)
          expect(user_via_float.verified).to eq(true)
        end
      end

      context "when using a date type" do
        it "returns records using order asc" do
          user_via_date = CrudTesting.order(dob: :asc).first

          expect(user_via_date).to_not be(nil)
          expect(user_via_date.dob).to eq(Date.new(1947,9,22))
        end

        it "returns records using order desc" do
          user_via_date = CrudTesting.order(dob: :desc).first

          expect(user_via_date).to_not be(nil)
          expect(user_via_date.dob).to eq(Date.new(1993,3,11))
        end
      end

      context "when using a datetime type" do
        it "returns records using order asc" do
          user_via_datetime = CrudTesting.order(last_login: :asc).first

          expect(user_via_datetime).to_not be(nil)
          expect(user_via_datetime.last_login).to eq(DateTime.new(2020,9,14))
        end

        it "returns records using order desc" do
          user_via_datetime = CrudTesting.order(last_login: :desc).first

          expect(user_via_datetime).to_not be(nil)
          expect(user_via_datetime.last_login).to eq(DateTime.new(2022,10,12))
        end
      end

      context "when using a float type" do
        it "returns records using order asc" do
          user_via_float = CrudTesting.order(latitude: :asc).first

          expect(user_via_float).to_not be(nil)
          expect(user_via_float.latitude).to eq(109.634496)
        end

        it "returns records using order desc" do
          user_via_float = CrudTesting.order(latitude: :desc).first

          expect(user_via_float).to_not be(nil)
          expect(user_via_float.latitude).to eq(125.634496)
        end
      end

      context "when using a combination of fields and queries" do
        before(:each) do
          PlaintextTesting.create([
            {
              dob: Date.new(1947,9,22),
              last_login: DateTime.new(2022,10,12),
              age_plaintext: 82,
              verified: false,
              latitude: 113.634496,
              email_plaintext: "kingsley.zissou@belafonte.com"
            },
            {
              dob: Date.new(1940,9,22),
              last_login: DateTime.new(2021,10,12),
              age_plaintext: 82,
              verified: true,
              latitude: 113.634496,
              email_plaintext: "steve.zissou@belafonte.com"
            },
            {
              dob: Date.new(1962,9,22),
              last_login: DateTime.new(2021,10,12),
              age_plaintext: 60,
              verified: true,
              latitude: 113.634496,
              email_plaintext: "steve.zissou@belafonte.com"
            }
          ])
        end

        it "returns ordered records using both plaintext and encrypted fields" do
          users = PlaintextTesting.order(:age_plaintext, last_login: :asc)
          expect(users.first).to_not be(nil)
          expect(users.first.age_plaintext).to eq(60)

          expect(users.last.age_plaintext).to eq(82)
          expect(users.last.last_login).to eq(DateTime.new(2022,10,12))
        end

        it "returns records using a where clause with encrypted values" do
          users_via_where = CrudTesting.where(age: ...75).order(age: :asc)

          expect(users_via_where.length).to eq(3)
          expect(users_via_where.first.age).to eq(29)
        end

        it "returns records using a where clause with plaintext values" do
          pt_users_via_where = PlaintextTesting.where(email_plaintext: "steve.zissou@belafonte.com").order(age_plaintext: :desc)

          expect(pt_users_via_where.length).to eq(2)
          expect(pt_users_via_where.first.age_plaintext).to eq(82)
          expect(pt_users_via_where.last.age_plaintext).to eq(60)
        end
      end
    end

    describe "#select" do
      it "returns records with only the selected fields" do
        user = CrudTesting.select(:age, :latitude).first

        expect(user.age).to_not be(nil)
        expect(user.latitude).to_not be(nil)

        expect { user.email }.to raise_error ActiveModel::MissingAttributeError
        expect { user.last_login }.to raise_error ActiveModel::MissingAttributeError
        expect { user.dob }.to raise_error ActiveModel::MissingAttributeError
        expect { user.verified }.to raise_error ActiveModel::MissingAttributeError
      end

      it "returns records when used with a where clause" do
        users = CrudTesting.select(:age).where(age: ..72).order(age: :desc)

        expect(users.length).to eq(3)
        expect(users.first.age).to eq(72)
      end
    end
  end

  describe "Read secure_text_search" do
    let(:model) {
      Class.new(ActiveRecord::Base) do
        self.table_name = CrudTesting.table_name
        secure_search :email
        secure_text_search :email,
          filter_size: 1024, filter_term_bits: 6,
          bloom_filter_id: "4f108250-53f8-013b-0bb5-0e015c998817",
          tokenizer: { kind: :standard },
          token_filters: [{kind: :downcase}, {kind: :ngram, min_length: 3, max_length: 8}]
      end
    }

    let(:model_without_secure_text_search) {
      Class.new(ActiveRecord::Base) do
        self.table_name = CrudTesting.table_name
      end
    }

    let(:model_multiple_field_search) {
       Class.new(ActiveRecord::Base) do
        self.table_name = CrudTesting.table_name

        secure_search :email
        secure_text_search :email,
          filter_size: 1024, filter_term_bits: 6,
          bloom_filter_id: "4f108250-53f8-013b-0bb5-0e015c998817",
          tokenizer: { kind: :standard },
          token_filters: [{kind: :downcase}, {kind: :ngram, min_length: 3, max_length: 8}]

        secure_search :suburb
        secure_text_search :suburb,
          filter_size: 1024, filter_term_bits: 6,
          bloom_filter_id: "4f108250-53f8-013b-0bb5-0e015c998817",
          tokenizer: { kind: :standard },
          token_filters: [{kind: :downcase}, {kind: :ngram, min_length: 3, max_length: 8}]
      end
    }

    context "when using a match query" do
      it "raises an error if no query arg is passed" do
        expect {
          model.match()
        }.to raise_error(CipherStash::Protect::Error, "Unable to execute text match query. Incorrect args passed. Example usage: model.match(email: 'test')")
      end

      [nil, 2, Object.new(), {foo: "bar"}, 2.3, []].each do |type|
        it "raises an error if type #{type.inspect} is passed" do

          expect {
            model.match(email: type)
          }.to raise_error(CipherStash::Protect::Error, "Value passed to match query for field email must be of type String. Got #{type.inspect()}.")
        end
      end

      it "raises error if a match query is made on an attribute that isn't a searchable text attribute" do
        expect {
          model_without_secure_text_search.match(full_name: "John")
        }.to raise_error(CipherStash::Protect::Error, "Unable to execute text match query. Attribute: full_name does not have a secure_text_search column.")
      end

      it "returns records when using partial string as value" do
        model.insert_all([
          { email: "dannie@hahn.name" },
          { email: "danna@cummings.info" },
          { email: "marybeth@kertzmann-bailey.org" },
          { email: "mariann@williamson.org" },
          { email: "marissa@hartmann.com" },
        ])

        expect(model.all.length).to eq(5)

        users = model.match(email: "dan")

        sorted_users = users.sort_by { |u| u.email}

        expect(sorted_users.length).to eq(2)
        expect(sorted_users.first.email).to eq("danna@cummings.info")
        expect(sorted_users.second.email).to eq("dannie@hahn.name")
      end

      it "returns records when using a combination of raw sql query and match query" do
        model.insert_all([
          { full_name: "Mary Bailey", email: "marybeth@kertzmann-bailey.org" },
          { full_name: "Mariann Williamson", email: "mariann@williamson.org" },
          { full_name: "Marissa Hartman", email: "marissa@hartmann.com" },
          { full_name: "Dannie Hahn", email: "dannie@hahn.name" },
          { full_name: "Greta Gerwig", email: "greta@gerwig.com" },
          { full_name: "Danna Cummings", email: "danna@cummings.info" },
        ])
        q = "Greta"
        criteria = "%#{q.downcase}%"

        query = <<~SQL.squish
          (lower(full_name) like ?)
        SQL

        users = model.where(query, criteria).or(model.match(email: "dan"))
        sorted_users = users.sort_by { |u| u.email}

        expect(sorted_users.length).to eq(3)
        expect(sorted_users.first.email).to eq("danna@cummings.info")
        expect(sorted_users.second.email).to eq("dannie@hahn.name")
        expect(sorted_users.last.email).to eq("greta@gerwig.com")
      end

      it "returns records using a match query with multiple args" do
         model_multiple_field_search.insert_all([
          { suburb: "Sydney", email: "marybeth@kertzmann-bailey.org" },
          { suburb: "Blaxland", email: "mariann@williamson.org" },
          { suburb: "Sydney", email: "marissa@hartmann.com" },
          { suburb: "Nowra", email: "dannie@hahn.name" },
          { suburb: "Parramatta", email: "greta@gerwig.com" },
          { suburb: "Strathfield", email: "danna@cummings.info" },
        ])
        users = model_multiple_field_search.match(email: "mary", suburb: "syd")
        sorted_users = users.sort_by { |u| u.email}

        expect(sorted_users.length).to eq(1)
        expect(sorted_users.first.email).to eq("marybeth@kertzmann-bailey.org")
      end

      it "returns records using a match query with multiple args chained to an or query" do
        model_multiple_field_search.insert_all([
          { suburb: "Sydney", email: "marybeth@kertzmann-bailey.org" },
          { suburb: "Blaxland", email: "mariann@williamson.org" },
          { suburb: "Sydney", email: "marissa@hartmann.com" },
          { suburb: "Nowra", email: "dannie@hahn.name" },
          { suburb: "Parramatta", email: "greta@gerwig.com" },
          { suburb: "Strathfield", email: "danna@cummings.info" },
        ])
        users = model_multiple_field_search.match(email: "mary", suburb: "syd").or(model_multiple_field_search.match(email: "dann", suburb: "strat"))
        sorted_users = users.sort_by { |u| u.email}

        expect(sorted_users.length).to eq(2)
        expect(sorted_users.first.email).to eq("danna@cummings.info")
        expect(sorted_users.second.email).to eq("marybeth@kertzmann-bailey.org")
      end

      it "returns records using a match query on multiple fields with or" do
        model_multiple_field_search.insert_all([
          { suburb: "Sydney", email: "marybeth@kertzmann-bailey.org" },
          { suburb: "Blaxland", email: "mariann@williamson.org" },
          { suburb: "Sydney", email: "marissa@hartmann.com" },
          { suburb: "Nowra", email: "dannie@hahn.name" },
          { suburb: "Parramatta", email: "greta@gerwig.com" },
          { suburb: "Strathfield", email: "danna@cummings.info" },
        ])

        users = model_multiple_field_search.match(suburb: "Syd").or(model_multiple_field_search.match(email: "mary"))

        sorted_users = users.sort_by { |u| u.email}

        expect(sorted_users.length).to eq(2)
        expect(sorted_users.first.email).to eq("marissa@hartmann.com")
        expect(sorted_users.second.email).to eq("marybeth@kertzmann-bailey.org")
      end

      it "returns records using a match query on multiple fields with and" do
        model_multiple_field_search.insert_all([
          { suburb: "Sydney", email: "marybeth@kertzmann-bailey.org" },
          { suburb: "Blaxland", email: "mariann@williamson.org" },
          { suburb: "Sydney", email: "marissa@hartmann.com" },
          { suburb: "Nowra", email: "dannie@hahn.name" },
          { suburb: "Parramatta", email: "greta@gerwig.com" },
          { suburb: "Strathfield", email: "danna@cummings.info" },
        ])

        users = model_multiple_field_search.match(suburb: "Syd").and(model_multiple_field_search.match(email: "mary"))

        sorted_users = users.sort_by { |u| u.email}

        expect(sorted_users.length).to eq(1)
        expect(sorted_users.first.email).to eq("marybeth@kertzmann-bailey.org")
      end
    end
  end
end

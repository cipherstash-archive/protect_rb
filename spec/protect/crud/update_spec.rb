RSpec.describe CipherStash::Protect::Model::CRUD do
  let(:ore_type) { CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1 }

  describe "Updates ore encrypted column" do
    before(:each) do
      CrudTesting.create!(
        dob: Date.new(1970,6,26),
        last_login: DateTime.new(2022,10,9),
        age: 52,
        verified: false,
        latitude: 150.634496,
        email: "pt.anderson@magnolia.com"
      )

      CrudTesting.create!(
        dob: Date.new(1954,8,16),
        last_login: DateTime.new(2022,10,9),
        age: 68,
        verified: false,
        latitude: 150.634496,
        email: "j.cameron@avatar.com"
      )

      CrudTesting.create!(
        dob: Date.new(1983,8,4),
        last_login: DateTime.new(2022,10,9),
        age: 39,
        verified: false,
        latitude: 150.634496,
        email: "frances.ha@gerwig.com"
      )
    end

    context "when using #update" do
      it "updates the ore and lockbox encrypted values in a single record" do
        user_one = CrudTesting.create!(
          dob: Date.new(1969,5,1),
          last_login: DateTime.new(2022,10,14),
          age: 53,
          verified: true,
          latitude: 150.634496,
          email: "wes.anderson@rushmore.com"
        )

        CrudTesting.update(user_one.id, verified: false, email: "wes@anderson.com")

        # Query using updated values.
        updated_user = CrudTesting.where(
          email_secure_search: ore_type.encrypt("wes@anderson.com"),
          verified_secure_search: ore_type.encrypt(false)
        )

        # Check that updated values are in DB.
        expect(updated_user.length).to eq(1)
        expect(updated_user.first.id).to eq(user_one.id)
        expect(updated_user.first.email).to eq("wes@anderson.com")
        expect(updated_user.first.verified).to eq(false)

        # Check existing values remain unchanged.
        expect(updated_user.first.last_login).to eq(user_one.last_login)
        expect(updated_user.first.dob).to eq(user_one.dob)
        expect(updated_user.first.age).to eq(user_one.age)
        expect(updated_user.first.latitude).to eq(user_one.latitude)
      end
    end

    if RAILS_VERSION >= 7
      context "when using #update!" do
        it "updates the ore and lockbox encrypted values in a single record" do
          user_one = CrudTesting.create!(
            dob: Date.new(1969,5,1),
            last_login: DateTime.new(2022,10,14),
            age: 53,
            verified: true,
            latitude: 150.634496,
            email: "wes.anderson@rushmore.com"
          )

          CrudTesting.update!(user_one.id, verified: false, email: "wes@anderson.com")

          # Query using updated values.
          updated_user = CrudTesting.where(
            email_secure_search: ore_type.encrypt("wes@anderson.com"),
            verified_secure_search: ore_type.encrypt(false)
          )

          # Check that updated values are in DB.
          expect(updated_user.length).to eq(1)
          expect(updated_user.first.id).to eq(user_one.id)
          expect(updated_user.first.email).to eq("wes@anderson.com")
          expect(updated_user.first.verified).to eq(false)

          # Check existing values remain unchanged.
          expect(updated_user.first.last_login).to eq(user_one.last_login)
          expect(updated_user.first.dob).to eq(user_one.dob)
          expect(updated_user.first.age).to eq(user_one.age)
          expect(updated_user.first.latitude).to eq(user_one.latitude)
        end
      end
    end

    context "when using #update_all" do
      it "updates the ore and lockbox encrypted values in multiple records", :skip => "update_all not implemented yet" do
        CrudTesting.update_all(verified:true)

        updated_users = CrudTesting.all

        updated_users.each do |user|
          expect(user.verified).to eq(true)
        end
      end

      it "updates the ore and lockbox encrypted values in multiple records with a where clause", :skip => "update_all not implemented yet" do
        existing_users = CrudTesting.where(
          last_login_secure_search: ore_type.encrypt(DateTime.new(2022,10,9))
        )

        expect(existing_users.length).to eq(3)

        existing_users.each do |user|
          expect(user.verified).to eq(false)
        end

        # This does not trigger any callbacks, so the virtual attribute isn't created.
        # We get a postgres undefined column error for verified.
        existing_users.update_all(verified:true)

        updated_users = CrudTesting.where(
          last_login_secure_search: ore_type.encrypt(DateTime.new(2022,10,9))
        )

        expect(updated_users.length).to eq(3)
        updated_users.each do |user|
          expect(user.verified).to eq(true)
        end
      end
    end

    context "when using #upsert" do
      it "updates a single record with ore and lockbox encrypted values" do
        existing_user = CrudTesting.where(email_secure_search:  ore_type.encrypt("frances.ha@gerwig.com"))
        expect(existing_user.length).to eq(1)

        # Update latitude and email
        CrudTesting.upsert({
          id: existing_user.first.id,
          dob: Date.new(1983,8,4),
          last_login: DateTime.new(2022,10,9),
          age: 39,
          verified: false,
          latitude: 10.000,
          email: "greta.gerwig@test.com"
        })

        # Assert Lockbox values are updated
        updated_user_by_id = CrudTesting.find_by(id: existing_user.first.id)
        expect(updated_user_by_id.latitude).to eq(10.000)
        expect(updated_user_by_id.email).to eq("greta.gerwig@test.com")

        # Find by secure search to assert protect rb fields have been updated.
        updated_user = CrudTesting.where(email_secure_search: ore_type.encrypt("greta.gerwig@test.com"))

        expect(updated_user.length).to eq(1)
        expect(updated_user.first.latitude).to eq(10.000)
        expect(updated_user.first.email).to eq("greta.gerwig@test.com")
      end

      it "creates a single record with ore and lockbox encrypted values" do
        CrudTesting.upsert({
         dob: Date.new(1969,3,9),
         last_login: DateTime.new(2022,10,9),
         age: 53,
         verified: true,
         latitude: 150.634496,
         email: "noah.baumbach@whale.com"
       })

        created_user = CrudTesting.where(
          email_secure_search: ore_type.encrypt("noah.baumbach@whale.com")
        )

        expect(created_user.length).to eq(1)
        expect(created_user.first.age).to eq(53)

        expect(created_user.first.email_secure_search).to_not be(nil)
      end
    end

    context "when using #upsert_all" do
      it "updates multiple records with ore and lockbox encrypted values" do
        existing_user = CrudTesting.where(email_secure_search: ore_type.encrypt("frances.ha@gerwig.com"))
        expect(existing_user.length).to eq(1)

        CrudTesting.upsert_all([{
          id: existing_user.first.id,
          dob: Date.new(1983,8,4),
          last_login: DateTime.new(2022,10,9),
          age: 39,
          verified: false,
          latitude: 10.000,
          email: "greta.gerwig@test.com"
        }])

        # Assert Lockbox values are updated
        updated_user_by_id = CrudTesting.find_by(id: existing_user.first.id)
        expect(updated_user_by_id.latitude).to eq(10.000)
        expect(updated_user_by_id.email).to eq("greta.gerwig@test.com")

        # Find by secure search to assert protect rb fields have been updated.
        updated_user = CrudTesting.where(email_secure_search: ore_type.encrypt("greta.gerwig@test.com"))

        expect(updated_user.length).to eq(1)
        expect(updated_user.first.email_secure_search).to_not be(nil)

        expect(updated_user.first.latitude).to eq(10.000)
        expect(updated_user.first.email).to eq("greta.gerwig@test.com")
      end

      it "creates multiples records with ore and lockbox encrypted values" do
        CrudTesting.upsert_all([
          {
            dob: Date.new(1969,3,9),
            last_login: DateTime.new(2022,10,9),
            age: 53,
            verified: true,
            latitude: 150.634496,
            email: "noah.baumbach@whale.com"
          },
          {
            dob: Date.new(1983,8,4),
            last_login: DateTime.new(2022,10,9),
            age: 39,
            verified: false,
            latitude: 10.000,
            email: "greta.gerwig@test.com"
          }
        ])

        user_one = CrudTesting.where(
          email_secure_search: ore_type.encrypt("noah.baumbach@whale.com")
        )
        expect(user_one.length).to eq(1)
        expect(user_one.first.email_secure_search).to_not be(nil)
        expect(user_one.first.email).to eq("noah.baumbach@whale.com")

        user_two = CrudTesting.where(
          email_secure_search: ore_type.encrypt("greta.gerwig@test.com")
        )

        expect(user_two.length).to eq(1)
        expect(user_two.first.email_secure_search).to_not be(nil)
        expect(user_two.first.email).to eq("greta.gerwig@test.com")
      end
    end
  end

  describe "Updates bloom filter encrypted column" do
    # TODO Update to use where clause when querying implemented, using subset checks in the interim
    VALID_BLOOM_FILTER_ID = "4f108250-53f8-013b-0bb5-0e015c998818"
    FILTER_SIZE = 256
    FILTER_TERM_BITS = 3
    TOKEN_FILTERS = [{kind: :downcase}, {kind: :ngram, token_length: 3}]
    TOKENIZER = { kind: :standard }

    let(:model) {
      Class.new(ActiveRecord::Base) do
        self.table_name = CrudTesting.table_name

        secure_text_search :email,
          filter_size: FILTER_SIZE,filter_term_bits: FILTER_TERM_BITS,
          bloom_filter_id: VALID_BLOOM_FILTER_ID,
          tokenizer: TOKENIZER,
          token_filters: TOKEN_FILTERS
      end
    }

    let(:filter) {
      CipherStash::Protect::ActiveRecordExtensions::BloomFilter.new(VALID_BLOOM_FILTER_ID,
        {
          filter_size: FILTER_SIZE,
          filter_term_bits: FILTER_TERM_BITS
        }
      )
    }

    let(:text_processor) {
      CipherStash::Protect::Analysis::TextProcessor.new(
        {
          token_filters: TOKEN_FILTERS,
          tokenizer: TOKENIZER
        }
      )
    }

    context "when using #update" do
      it "updates the bloom filter and lockbox encrypted values in a single record" do
        user_one = model.create!(
          email: "wes.anderson@rushmore.com"
        )

        model.update(user_one.id, email: "owen.wilson@bottlerocket.com")

        updated_user = model.find_by(id: user_one.id)

        tokens = text_processor.perform("owen.wilson@bottlerocket.com")
        bits = filter.add(tokens).postgres_bits_from_native_bits

        expect((bits - updated_user.email_secure_text_search).empty?).to be(true)
        expect(updated_user.email).to eq("owen.wilson@bottlerocket.com")
      end
    end

    if RAILS_VERSION >= 7
      context "when using #update!" do
        it "updates the bloom filter and lockbox encrypted values in a single record" do
          user_one = model.create!(
            email: "wes.anderson@rushmore.com"
          )

          model.update!(user_one.id, email: "owen.wilson@bottlerocket.com")

          updated_user = model.find_by(id: user_one.id)

          tokens = text_processor.perform("owen.wilson@bottlerocket.com")
          bits = filter.add(tokens).postgres_bits_from_native_bits

          expect((bits - updated_user.email_secure_text_search).empty?).to be(true)
          expect(updated_user.email).to eq("owen.wilson@bottlerocket.com")
        end
      end
    end

    context "when using #upsert" do
      it "updates a single record with bloom filter and lockbox encrypted values" do
        user_one = model.create!(
          email: "wes.anderson@rushmore.com"
        )

        model.upsert({
          id: user_one.id,
          email: "greta.gerwig@test.com"
        })

        updated_user = model.find_by(id: user_one.id)

        tokens = text_processor.perform("greta.gerwig@test.com")
        bits = filter.add(tokens).postgres_bits_from_native_bits

        expect((bits - updated_user.email_secure_text_search).empty?).to be(true)
        expect(updated_user.email).to eq("greta.gerwig@test.com")
      end

      it "creates a single record with bloom filter and lockbox encrypted values", :skip => "add when bloom filter querying added" do
      end
    end

    context "when using #upsert_all" do
      it "updates multiple records with bloom filter and lockbox encrypted values" do
        user_one = model.create!(
          email: "wes.anderson@rushmore.com"
        )

        model.upsert_all([{
          id: user_one.id,
          email: "greta.gerwig@test.com"
        }])

        updated_user = model.find_by(id: user_one.id)

        tokens = text_processor.perform("greta.gerwig@test.com")
        bits = filter.add(tokens).postgres_bits_from_native_bits

        expect((bits - updated_user.email_secure_text_search).empty?).to be(true)
        expect(updated_user.email).to eq("greta.gerwig@test.com")
      end

      it "creates records with bloom filter and lockbox encrypted values" do
        model.upsert_all([
          {
            email: "noah.baumbach@whale.com"
          }
        ])

        users = model.all
        expect(users.length).to eq(1)


        tokens = text_processor.perform("noah.baumbach@whale.com")
        bits = filter.add(tokens).postgres_bits_from_native_bits
        expect(users.first.email).to eq("noah.baumbach@whale.com")
        expect((bits - users.first.email_secure_text_search).empty?).to be(true)
      end
    end
  end
end

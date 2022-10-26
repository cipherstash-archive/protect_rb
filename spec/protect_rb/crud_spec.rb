RSpec.describe ProtectRB::Model::CRUD do
  # TODO Split out crud specs to different files
  describe "Create" do
    context "create" do
      it "creates a single record with ore and lockbox encrypted values" do
        user = CrudTesting.create(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: 84,
          verified: true,
          latitude: 150.634496,
          email: "steve.zissou@belafonte.com"
        )

        expect(user.age_secure_search).to_not be(nil)
        expect(user.age_secure_search.class).to eq(ProtectRB::ActiveRecordExtensions::ORE_64_8_V1)
        expect(user.age_secure_search.ciphertext).to_not be(nil)

        expect(user.age_ciphertext).to_not be(nil)

        returned_user = CrudTesting.where(age_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(84))

        expect(returned_user.first.id).to eq(user.id)
      end
    end

    context "create!" do
      it "creates a single record with ore and lockbox encrypted values" do
        user = CrudTesting.create!(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: 84,
          verified: true,
          latitude: 150.634496,
          email: "steve.zissou@belafonte.com"
        )

        expect(user.age_secure_search).to_not be(nil)
        expect(user.age_secure_search.class).to eq(ProtectRB::ActiveRecordExtensions::ORE_64_8_V1)
        expect(user.age_secure_search.ciphertext).to_not be(nil)

        expect(user.age_ciphertext).to_not be(nil)

        returned_user = CrudTesting.where(age_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(84))

        expect(returned_user.first.id).to eq(user.id)
      end
    end

    context "insert_all" do
      it "creates multiple records with ore and lockbox encrypted values" do
        CrudTesting.insert_all([
            {
              dob: Date.new(1950,9,21),
              last_login: DateTime.new(2022,10,14),
              age: 84,
              verified: true,
              latitude: 150.634496,
              email: "steve.zissou@belafonte.com"
            },
            {
              dob: Date.new(1970,6,26),
              last_login: DateTime.new(2022,10,9),
              age: 52,
              verified: false,
              latitude: 150.634496,
              email: "pt.anderson@magnolia.com"
            },
          ]
        )

        user_one = CrudTesting.where(
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("steve.zissou@belafonte.com")
        )
        expect(user_one.length).to eq(1)
        expect(user_one.first.email_secure_search).to_not be(nil)
        expect(user_one.first.email).to eq("steve.zissou@belafonte.com")

        user_two = CrudTesting.where(
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("pt.anderson@magnolia.com")
        )

        expect(user_two.length).to eq(1)
        expect(user_two.first.email_secure_search).to_not be(nil)
        expect(user_two.first.email).to eq("pt.anderson@magnolia.com")
      end
    end

    context "insert_all!" do
      it "creates multiple records with ore and lockbox encrypted values" do
        CrudTesting.insert_all!([
            {
              dob: Date.new(1950,9,21),
              last_login: DateTime.new(2022,10,14),
              age: 84,
              verified: true,
              latitude: 150.634496,
              email: "steve.zissou@belafonte.com"
            },
            {
              dob: Date.new(1970,6,26),
              last_login: DateTime.new(2022,10,9),
              age: 52,
              verified: false,
              latitude: 150.634496,
              email: "pt.anderson@magnolia.com"
            },
          ]
        )

        user_one = CrudTesting.where(
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("steve.zissou@belafonte.com")
        )
        expect(user_one.length).to eq(1)
        expect(user_one.first.email_secure_search).to_not be(nil)
        expect(user_one.first.email).to eq("steve.zissou@belafonte.com")

        user_two = CrudTesting.where(
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("pt.anderson@magnolia.com")
        )

        expect(user_two.length).to eq(1)
        expect(user_two.first.email_secure_search).to_not be(nil)
        expect(user_two.first.email).to eq("pt.anderson@magnolia.com")
      end
    end
  end

  describe "Updates" do
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

    context "update" do
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
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("wes@anderson.com"),
          verified_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(false)
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

    context "update!" do
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
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("wes@anderson.com"),
          verified_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(false)
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

    context "update_all" do
      it "updates the ore and lockbox encrypted values in multiple records", :skip => "update_all not implemented yet" do
        CrudTesting.update_all(verified:true)

        updated_users = CrudTesting.all

        updated_users.each do |user|
          expect(user.verified).to eq(true)
        end
      end

      it "updates the ore and lockbox encrypted values in multiple records with a where clause", :skip => "update_all not implemented yet" do
        existing_users = CrudTesting.where(
          last_login_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(DateTime.new(2022,10,9))
        )

        expect(existing_users.length).to eq(3)

        existing_users.each do |user|
          expect(user.verified).to eq(false)
        end

        # This does not trigger any callbacks, so the virtual attribute isn't created.
        # We get a postgres undefined column error for verified.
        existing_users.update_all(verified:true)

        updated_users = CrudTesting.where(
          last_login_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(DateTime.new(2022,10,9))
        )

        expect(updated_users.length).to eq(3)
        updated_users.each do |user|
          expect(user.verified).to eq(true)
        end
      end
    end

    context "upsert" do
      it "updates a single record with ore and lockbox encrypted values" do
        existing_user = CrudTesting.where(email_secure_search:  ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("frances.ha@gerwig.com"))
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
        updated_user = CrudTesting.where(email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("greta.gerwig@test.com"))

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
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("noah.baumbach@whale.com")
        )

        expect(created_user.length).to eq(1)
        expect(created_user.first.age).to eq(53)

        expect(created_user.first.email_secure_search).to_not be(nil)
      end
    end

    context "upsert_all" do
      it "updates multiple records with ore and lockbox encrypted values" do
        existing_user = CrudTesting.where(email_secure_search:  ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("frances.ha@gerwig.com"))
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
        updated_user = CrudTesting.where(email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("greta.gerwig@test.com"))

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
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("noah.baumbach@whale.com")
        )
        expect(user_one.length).to eq(1)
        expect(user_one.first.email_secure_search).to_not be(nil)
        expect(user_one.first.email).to eq("noah.baumbach@whale.com")

        user_two = CrudTesting.where(
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("greta.gerwig@test.com")
        )

        expect(user_two.length).to eq(1)
        expect(user_two.first.email_secure_search).to_not be(nil)
        expect(user_two.first.email).to eq("greta.gerwig@test.com")
      end
    end
  end

  describe "Read" do
    before(:each) do
       CrudTesting.create!(
        dob: Date.new(1950,9,21),
        last_login: DateTime.new(2020,9,14),
        age: 72,
        verified: true,
        latitude: 125.634496,
        email: "steve.zissou@belafonte.com"
      )

      CrudTesting.create!(
        dob: Date.new(1947,9,22),
        last_login: DateTime.new(2022,10,12),
        age: 75,
        verified: false,
        latitude: 113.634496,
        email: "kingsley.zissou@belafonte.com"
      )

      CrudTesting.create!(
        dob: Date.new(1967,9,27),
        last_login: DateTime.new(2022,7,1),
        age: 55,
        verified: false,
        latitude: 109.634496,
        email: "royal@tenenbaum.com"
      )

      CrudTesting.create!(
        dob: Date.new(1993,3,11),
        last_login: DateTime.new(2022,8,7),
        age: 29,
        verified: true,
        latitude: 115.634496,
        email: "etheline@tenenbaum.com"
      )
    end

    context "equality" do
      it "returns records on an integer type" do
        user_via_integer = CrudTesting.where(age_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(72))

        expect(user_via_integer.length).to eq(1)
        expect(user_via_integer.first.age).to eq(72)
      end

      it "returns records on a boolean type" do
        user_via_boolean = CrudTesting.where(
          verified_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(true)
        )

        expect(user_via_boolean.length).to eq(2)
        expect(user_via_boolean.first.verified).to eq(true)
        expect(user_via_boolean.second.verified).to eq(true)
      end

      it "returns records on a date type" do
        user_via_date = CrudTesting.where(
          dob_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(Date.new(1967,9,27))
        )

        expect(user_via_date.length).to eq(1)
        expect(user_via_date.first.dob).to eq(Date.new(1967,9,27))
      end

      it "returns records on a date time type" do
        user_via_datetime = CrudTesting.where(
          last_login_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(DateTime.new(2022,8,7))
        )

        expect(user_via_datetime.length).to eq(1)
        expect(user_via_datetime.first.last_login).to eq(DateTime.new(2022,8,7))
      end

      it "returns records on a float type" do
        user_via_float = CrudTesting.where(
          latitude_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(109.634496)
        )

        expect(user_via_float.length).to eq(1)
        expect(user_via_float.first.latitude).to eq(109.634496)
      end

      it "returns records on a string type" do
        user_via_string = CrudTesting.where(
          email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("etheline@tenenbaum.com")
        )

        expect(user_via_string.length).to eq(1)
        expect(user_via_string.first.email).to eq("etheline@tenenbaum.com")
      end

      it "should not return a record if querying on a nil secure search field" do
        user = CrudTesting.create(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: nil,
          verified: true,
          latitude: 150.634496,
          email: "test@email.com"
        )

        returned_user = CrudTesting.where(
          age_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(70)
        )
        expect(returned_user.length).to eq(0)
      end
    end

    context "range" do
      it "returns records using gt on an integer type" do
        user_via_integer = CrudTesting.where.not(age_secure_search: ..ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(72))

        expect(user_via_integer.length).to eq(1)
      end

      it "returns records using gte on an integer type" do
        user_via_integer = CrudTesting.where(age_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(72)..)

        expect(user_via_integer.length).to eq(2)
      end

      it "returns records using lt on an integer type" do
        user_via_integer = CrudTesting.where(age_secure_search: ...ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(72))

        expect(user_via_integer.length).to eq(2)
      end

      it "returns records using lte on an integer type" do
        user_via_integer = CrudTesting.where(age_secure_search: ..ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(72))

        expect(user_via_integer.length).to eq(3)
      end
    end
  end
end

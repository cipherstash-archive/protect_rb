RSpec.describe ProtectRB::Model::CRUD do
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
          user_via_datetime = CrudTesting.find_by(last_login: DateTime.new(2022,8,7))

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

      context "when using a combination of fields" do
        it "returns records using both plaintext and encrypted fields" do
          user_one = PlaintextTesting.create(
            dob: Date.new(1947,9,22),
            last_login: DateTime.new(2022,10,12),
            age_plaintext: 82,
            verified: false,
            latitude: 113.634496,
            email_plaintext: "kingsley.zissou@belafonte.com"
          )

          user_two = PlaintextTesting.create(
            dob: Date.new(1940,9,22),
            last_login: DateTime.new(2021,10,12),
            age_plaintext: 82,
            verified: true,
            latitude: 113.634496,
            email_plaintext: "steve.zissou@belafonte.com"
          )

          user_three = PlaintextTesting.create(
            dob: Date.new(1962,9,22),
            last_login: DateTime.new(2021,10,12),
            age_plaintext: 60,
            verified: true,
            latitude: 113.634496,
            email_plaintext: "steve.zissou@belafonte.com"
          )

          first_user = PlaintextTesting.order(:age_plaintext, last_login: :asc).first

          expect(first_user).to_not be(nil)
          expect(first_user.id).to eq(user_three.id)

          last_user = PlaintextTesting.order(:age_plaintext, last_login: :asc).last
          expect(last_user.id).to eq(user_one.id)
        end
      end
    end
  end
end

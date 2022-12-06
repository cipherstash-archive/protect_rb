RSpec.describe "CipherStash::Protect::Model Creation Validates" do
  describe "Validates presence true" do
    let(:model) {
      Class.new(ActiveRecord::Base) do
        self.table_name = 'users_for_validates_testing'
        def self.model_name
          ActiveModel::Name.new(self, nil, "validations")
        end

        validates :email, presence: true

        secure_search :email
      end
    }

    it "a record is created if the field is not nil" do
      expect { model.create!(email: "blah@test.com") }.to_not raise_error()
    end

    it "should raise an error if the field is nil" do
      expect { model.create!(email: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

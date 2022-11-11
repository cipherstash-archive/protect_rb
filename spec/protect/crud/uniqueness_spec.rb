RSpec.describe "Protect::Model Creation Uniqueness" do
  describe "UNIQUE-indexed columns" do
    let(:model) {
      Class.new(ActiveRecord::Base) do
        self.table_name = 'users_for_uniqueness_testing'

        secure_search :example_index, type: :string
        # Has a UNIQUE index; see spec/support/migrations/500_create_*.rb
      end
    }

    it "raises RecordNotUnique on duplicates" do
      value = 'example123'
      user = model.create(
        example_index: value,
      )
      expect(user.example_index).to eq value

      [value.reverse, value.upcase].map do |other_value|
        model.create(example_index: other_value)
        expect(
          model.find_by(example_index: other_value).example_index
        ).to eql other_value
      end

      expect {
        model.create(
          example_index: value,
        )
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "Uniqueness validation" do
    let(:model) {
      Class.new(ActiveRecord::Base) do
        self.table_name = 'users_for_uniqueness_testing'
        def self.model_name
          ActiveModel::Name.new(self, nil, "uniqueness_validations")
        end

        secure_search :example_validation, type: :string
        validates :example_validation, uniqueness: true
      end
    }

    it "fails to save when the secure-search value is not unique" do
      value = 'example123'

      user1 = model.create(
        example_validation: value,
      )
      expect(user1.persisted?).to be true
      expect(user1.example_validation).to eq value
      expect(user1.errors).to be_empty

      user2 = model.create(
        example_validation: value,
      )
      expect(user2.persisted?).to be false
      expect(user2.errors).to_not be_empty
      expect(user2.errors[:example_validation].first).to match("has already been taken")
    end
  end
end

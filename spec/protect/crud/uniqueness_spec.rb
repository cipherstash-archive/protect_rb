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
end

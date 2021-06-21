RSpec.describe Users::Api::User do
  describe ".get_by_id" do
    context "when user exists" do
      it "fetches the user" do
        created_user = Users::Models::User.create!(email: "mrbean@hydepark.com")

        result = described_class.get_by_id(created_user.id)

        expect(result).to be_success
        expect(result.value!).to eq(created_user)
      end
    end

    context "when user does not exist" do
      it "returns a failure with user not found" do
        result = described_class.get_by_id(5)

        expect(result).to be_failure
        expect(result.failure).to eq({ code: :user_not_found })
      end
    end
  end
end

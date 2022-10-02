RSpec.describe Users::Api::User do
  def create_user
    Users::Models::User.create!(email: "mrbean@hydepark.com")
  end

  let(:shipping_params) do 
    Users::Api::DTO::ShippingParams.new(city: 'Cupertino', zip: '95014', street_address: 'One Apple Park Way')
  end

  describe ".get_by_id" do
    context "when user exists" do
      it "fetches the user" do
        created_user = create_user

        result = described_class.get_by_id(created_user.id)

        expect(result).to be_success
        expect(result.value!.to_h).to eq(created_user.attributes.symbolize_keys.except(:created_at, :updated_at))
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

  describe ".update_shipping_address" do
    context "when valid params given" do
      it 'updates shipping address' do
        user = create_user

        result = described_class.update_shipping_address(user.id, shipping_params)

        expect(result).to be_success
        expect(result.value!.to_h).to match(shipping_params.to_h.merge(id: kind_of(String), user_id: user.id))
      end
    end

    context "when user and his shipping address already exists" do
      it "updates shipping address to a new one" do
        user = create_user
        described_class.update_shipping_address(user.id, shipping_params)
        new_params = Users::Api::DTO::ShippingParams.new(city: 'Mountain View', 
                                                         zip: '1600', 
                                                         street_address: 'Amphitheatre Parkway')

        result = described_class.update_shipping_address(user.id, new_params)
        expect(result).to be_success
        expect(result.value!.to_h).to match(new_params.to_h.merge(id: kind_of(String), user_id: user.id))
      end
    end

    context "when invalid params given" do
      it "returns a failure with error messages" do
        user = create_user
        params = Users::Api::DTO::ShippingParams.new(city: '', zip: '', street_address: '')

        result = described_class.update_shipping_address(user.id, params)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :shipping_address_not_valid,
          details: { city: ["can't be blank"], zip: ["can't be blank"], street_address: ["can't be blank"] }
        )
      end
    end

    context "when user not found" do
      it "returns a failure with user not found" do
        result = described_class.update_shipping_address('invalid_id', shipping_params)

        expect(result).to be_failure
        expect(result.failure).to eq(code: :user_not_found)
      end
    end
  end
end

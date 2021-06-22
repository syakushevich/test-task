RSpec.describe Orders::Api::Order do
  describe ".create" do
    context "when valid params given" do
      it "creates the order" do
        order_params = Orders::Api::Dto::OrderParams.new(
          auction_id: 78,
          total_payment: 462.65
        )

        result = described_class.create(order_params)

        expect(result).to be_success
        expect(result.value!.to_h).to match(
          order_params.to_h.merge(
            id: kind_of(Integer),
            status: "draft",
            payment_method: nil,
            shipping_method: nil
          )
        )
      end
    end

    context "when 0 amount given" do
      it "returns a failure" do
        order_params = Orders::Api::Dto::OrderParams.new(
          auction_id: 78,
          total_payment: 0.0
        )

        result = described_class.create(order_params)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_created,
          details: { total_payment: ["must be greater than 0"] }
        )
      end
    end
  end
end

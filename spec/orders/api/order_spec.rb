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

  describe ".update_shipping_method" do
    context "when value given" do
      it "updates the order" do
        order = Orders::Models::Order.create(
          auction_id: 43,
          total_payment: 1500.0
        )

        result = described_class.update_shipping_method(order.id, "Fedex Overnight")

        expect(result).to be_success
        expect(result.value!.to_h).to match(
          order.attributes.symbolize_keys
            .except(:created_at, :updated_at)
            .merge(
              shipping_method: "Fedex Overnight"
            )
        )
      end
    end

    context "when blank value given" do
      it "returns a failure" do
        order = Orders::Models::Order.create(
          auction_id: 43,
          total_payment: 1500.0
        )

        result = described_class.update_shipping_method(order.id, "")

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_updated,
          details: { shipping_method: ["is too short (minimum is 1 character)"] }
        )
      end
    end
  end

  describe ".update_payment_method" do
    context "when value given" do
      it "updates the order" do
        order = Orders::Models::Order.create(
          auction_id: 43,
          total_payment: 1500.0
        )

        result = described_class.update_payment_method(order.id, "Stripe")

        expect(result).to be_success
        expect(result.value!.to_h).to match(
          order.attributes.symbolize_keys
            .except(:created_at, :updated_at)
            .merge(
              payment_method: "Stripe"
            )
        )
      end
    end

    context "when blank value given" do
      it "returns a failure" do
        order = Orders::Models::Order.create(
          auction_id: 43,
          total_payment: 1500.0
        )

        result = described_class.update_payment_method(order.id, "")

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_updated,
          details: { payment_method: ["is too short (minimum is 1 character)"] }
        )
      end
    end
  end
end

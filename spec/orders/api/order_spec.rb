RSpec.describe Orders::Api::Order do
  def prepare_order_params(total_payment = BigDecimal("1500.0"))
    {
      auction_id: "dfcf17c4-beba-4209-b9e6-2b303313470c",
      buyer_id: "b8c9ad09-084f-4c39-9b94-944e12efc736",
      total_payment: total_payment
    }
  end

  describe ".create" do
    context "when valid params given" do
      it "creates the order" do
        order_params = Orders::Api::DTO::OrderParams.new(prepare_order_params)

        result = described_class.create(order_params)

        expect(result).to be_success
        expect(result.value!.to_h).to match(
          order_params.to_h.merge(
            id: kind_of(String),
            status: "draft",
            reference_number: kind_of(String),
            payment_method: nil,
            shipping_method: nil
          )
        )
      end
    end

    context "when 0 amount given" do
      it "returns a failure" do
        order_params = Orders::Api::DTO::OrderParams.new(prepare_order_params(BigDecimal("0.0")))

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
        order = Orders::Models::Order.create(prepare_order_params.merge(status: "draft", reference_number: "abc"))

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
        order = Orders::Models::Order.create(prepare_order_params.merge(status: "draft", reference_number: "abc"))

        result = described_class.update_shipping_method(order.id, "")

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_updated,
          details: { shipping_method: ["is too short (minimum is 1 character)"] }
        )
      end
    end

    context "when order not found" do
      it "returns a failure" do
        result = described_class.ship(37)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_found
        )
      end
    end

    context "when order is shipped" do
      it "returns a failure" do
        order = Orders::Models::Order.create(prepare_order_params.merge(status: "draft", reference_number: "abc"))

        order.update(status: "shipped")

        result = described_class.update_payment_method(order.id, "Stripe")

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_updated,
          details: { base: ["can't update shipped order"] }
        )
      end
    end
  end

  describe ".update_payment_method" do
    context "when value given" do
      it "updates the order" do
        order = Orders::Models::Order.create(prepare_order_params.merge(status: "draft", reference_number: "abc"))

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
        order = Orders::Models::Order.create(prepare_order_params.merge(status: "draft", reference_number: "abc"))

        result = described_class.update_payment_method(order.id, "")

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_updated,
          details: { payment_method: ["is too short (minimum is 1 character)"] }
        )
      end
    end

    context "when order not found" do
      it "returns a failure" do
        result = described_class.ship(37)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_found
        )
      end
    end

    context "when order is shipped" do
      it "returns a failure" do
        order = Orders::Models::Order.create(prepare_order_params.merge(status: "draft", reference_number: "abc"))

        order.update(status: "shipped")

        result = described_class.update_payment_method(order.id, "Stripe")

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_updated,
          details: { base: ["can't update shipped order"] }
        )
      end
    end
  end

  describe ".ship" do
    context "when order has shipping_method and payment_method set" do
      it "ships the order" do
        order = Orders::Models::Order.create(
          prepare_order_params.merge(
            status: "draft",
            reference_number: "abc",
            shipping_method: "AirForce One",
            payment_method: "gold"
          )
        )

        result = described_class.ship(order.id)

        expect(result).to be_success
        expect(result.value!.to_h).to match(
          order.attributes.symbolize_keys
            .except(:created_at, :updated_at)
            .merge(
              status: "shipped"
            )
        )
      end
    end

    context "when order has no shipping_method" do
      it "returns a failure with info about missing field" do
        order = Orders::Models::Order.create(
          prepare_order_params.merge(
            status: "draft",
            reference_number: "abc",
            payment_method: "gold"
          )
        )

        result = described_class.ship(order.id)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_shipped,
          details: { shipping_method: ["is missing"] }
        )
      end
    end

    context "when order has no payment_method" do
      it "returns a failure with info about missing field" do
        order = Orders::Models::Order.create(
          prepare_order_params.merge(
            status: "draft",
            reference_number: "abc",
            shipping_method: "AirForce One"
          )
        )

        result = described_class.ship(order.id)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_shipped,
          details: { payment_method: ["is missing"] }
        )
      end
    end

    context "when some invalid data present on the order" do
      it "returns a failure with info about the error" do
        order = Orders::Models::Order.create(
          prepare_order_params.merge(
            status: "draft",
            reference_number: "abc",
            shipping_method: "AirForce One",
            payment_method: "gold"
          )
        )

        order.update_column(:total_payment, -100)

        result = described_class.ship(order.id)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_shipped,
          details: { total_payment: ["must be greater than 0"] }
        )
      end
    end

    context "when order does not exist" do
      it "returns a failure" do
        result = described_class.ship(37)

        expect(result).to be_failure
        expect(result.failure).to eq(
          code: :order_not_found
        )
      end
    end
  end
end

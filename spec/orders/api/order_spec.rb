RSpec.describe Orders::Api::Order do
  let(:user) { Users::Models::User.create!(email: "mrbean@hydepark.com") }
  let(:auction) do
    Auctions::Models::Auction.create(
      name: "Leonardo da Vinci's pencil",
      creator_id: "e155fe2c-c588-4320-8acf-a1ff0d82190b",
      package_weight: 0.05,
      package_size_x: 0.03,
      package_size_y: 0.005,
      package_size_z: 0.002,
      finishes_at: Time.now + 1.day,
      status: "open"
    )
  end

  def prepare_order_params(total_payment = BigDecimal("1500.0"))
    {
      auction_id: auction.id,
      buyer_id: user.id,
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
            shipping_method: nil,
            total_order_price: order_params.total_payment
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
        shipping_method = "Fedyx Overnight"
        result = described_class.update_shipping_method(order.id, shipping_method)

        expect(result).to be_success
        expect(result.value!.to_h).to match(order.reload.order_params.except(:created_at, :updated_at))
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
        expect(result.value!.to_h).to match(order.reload.order_params.except(:created_at, :updated_at))
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
    let(:shipping_address_params) do 
      { city: 'Cupertino', zip: '95014', street_address: 'One Apple Park Way' } 
    end

    context "when user and shipping address present" do
      before(:each) do
        Users::Api::User.update_shipping_address(user.id, Users::Api::DTO::ShippingParams.new(shipping_address_params))
      end

      context "when order has shipping_method and payment_method set" do
        it "ships the order" do
          order = Orders::Models::Order.create(
            prepare_order_params.merge(
              buyer_id: user.id,
              status: "draft",
              reference_number: "abc",
              shipping_method: "UPZ Express",
              payment_method: "gold"
            )
          )

          result = described_class.ship(order.id)

          expect(result).to be_success
          expect(result.value!.to_h).to match(
            order.reload.order_params
              .except(:created_at, :updated_at)
              .merge(
                status: "shipped"
              ).merge(shipping_address_params)
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
              shipping_method: "UPZ Express"
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
              shipping_method: "UPZ Express",
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

    context "when user or shipping address are not present" do
      context "user is not present" do
        it "returns a failure" do
          order = Orders::Models::Order.create(
            auction_id: 'nonexistent-id',
            buyer_id: 'nonexistent-id',
            total_payment: 1500,
            status: "draft",
            reference_number: "abc",
            payment_method: "gold"
          )

          result = described_class.ship(order.id)

          expect(result).to be_failure
          expect(result.failure).to eq(code: :user_not_found)
        end
      end

      context "shipping address is not present" do
        it "returns a failure" do
          order = Orders::Models::Order.create(
            auction_id: 'nonexistent-id',
            buyer_id: user.id,
            total_payment: 1500,
            status: "draft",
            reference_number: "abc",
            payment_method: "gold"
          )

          result = described_class.ship(order.id)

          expect(result).to be_failure
          expect(result.failure).to eq(code: :shipping_address_not_found)
        end
      end
    end
  end
end

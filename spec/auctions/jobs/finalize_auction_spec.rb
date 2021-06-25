RSpec.describe Auctions::Jobs::FinalizeAuction do
  describe "#perform" do
    it "calls the API method for finalizing auction passing the auction id" do
      expect(Auctions::Api::Auction).to receive(:finalize).with(15)

      described_class.new.perform(15)
    end
  end
end

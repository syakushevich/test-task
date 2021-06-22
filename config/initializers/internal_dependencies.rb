# Dependency injections between modules
container = Dry::Container.new
container.register(:create_order) { |params| Orders::Api::Order.create(params) }

AuctionDependencies = Dry::AutoInject(container)

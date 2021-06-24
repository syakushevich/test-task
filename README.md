# GAT DevTest

## Installation and usage

This scaffold was created using Ruby 3.0. It is not a fully working application and was designed as a collection of modules
that can be injected into other applications.

To install dependencies:

```
bundle install
```

To initialize the database:

```
rake db:create
rake db:migrate
rake db:migrate APP_ENV=test
```

To load the seeds:

```
ruby bin/seed.rb
```

To explore the modules available here you can use - `bin/console`

To run specs run:

```
rspec
```

To remove the databases for the scaffold:

```
rake db:drop
```

## Context

This test is not about solving a problem. It's about execution and checking what's your default way of thinking and coding habits.
If you want to install any gems that can help you with solving the task, you are free to do so.

## General instructions

1. Fork this repository
2. All your changes should be made in a private fork of this repository.
3. All your changes should be made on a branch that is separate from master
4. When you're done, please, please:

- Create a Merge Request in your repository from the branch with changes to your master branch
- Share your fork with the @wojteko user (Settings -> Members -> Share with Member)
- Make sure that you grant the user the Reporter role so that our reviewers can check out the code using Git.

## Description

The code in this repository is a small extract from an auction site that allows users to create auctions, bid on them, and in the end redeem won items. Code is independent of the delivery mechanisms like HTTP and only operates as a set of ruby modules that could be plugged in into different frameworks.

To run the project you need a PostgreSQL database. This repository provides database schema that can be loaded using rake task as well as some seed data to populate the database.

Currently, modules support following actions to be performed:

- Create an auction
- Place a bid for an auction
- Finalize the auction
- Choose shipping method
- Choose payment method
- Ship the order

Modules should communicate with each other via their public APIs.

Your task within the test is to implement the code that will fulfil these acceptance criteria:

1. When the auction is finished, the system should send email notification to the winning bidder
2. When selecting the shipping method, a total order price should be calculated with added shipping cost:
   1. When shipping method A is selected, then the shipping price should be equal to weight rounded up to 1kg times $2,
   2. When shipping method B is selected, when the shipping price should be equal to package volume (in m3) times an id field fetched from https://official-joke-api.appspot.com/random_joke.
3. Add an action to Users module that would allow user to add shipping address to their data and when shipping the Order use the shipping address from the User. When the user doesn’t have one - throw an error. Shipping address should contain city, zip code and street address, all required strings.

# Ibancom

Ruby client for iban.com APIs (cf. <https://www.iban.com/developers>)

Run `bin/console` for an interactive prompt to experiment with the code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ibancom'
```

And then execute:

`$ bundle install`

Or install it yourself as:

`$ gem install ibancom`

### Supported APIs

This gem provides support for the following APIs:

- Validation API v4
- Sortware API v4

## Usage

The first step for using this gem is to instantiate the client:

```rb
client = Ibancom::Client.new(apikey: "YOUR_API_KEY")
```

Once you have an authenticated client, you can validate any IBAN easily by using the validations service:

```rb
# Request an IBAN validation
iban = client.validations.validate("ES8800758353964664433159")
iban.valid? # true

# What is the bank/branch associated to this account?
bank = iban.bank # <Ibancom::Resources::IBAN::Bank:0x00007f384a4b80f0 ...
bank.bank        # "BANCO SANTANDER, S.A."
bank.bic         # "BSCHESMMXXX"
bank.account     # "4664433159"
bank.bank_code   # "0075"
bank.branch_code # "8353"
bank.address     # "JUAN IGNACIO LUCA DE TENA 9-11"
bank.city        # "MADRID"
bank.state       # nil
bank.zip         # "28027"
bank.phone       # "0915207000"
bank.country     # "Spain"
bank.country_iso # "ES"

# What SEPA schemes does it support?
iban.supported_schemes
#[#<Ibancom::Resources::IBAN::Scheme:0x00007f384f37a710 @code=:SCT, @response=nil, @supported="YES">,
# #<Ibancom::Resources::IBAN::Scheme:0x00007f384f37a030 @code=:SCI, @response=nil, @supported="YES">,
# #<Ibancom::Resources::IBAN::Scheme:0x00007f384f379e50 @code=:SDD, @response=nil, @supported="YES">,
# #<Ibancom::Resources::IBAN::Scheme:0x00007f384f379d10 @code=:COR1, @response=nil, @supported="YES">,
# #<Ibancom::Resources::IBAN::Scheme:0x00007f384f379ba8 @code=:B2B, @response=nil, @supported="YES">]

# Does the IBAN supports instant transfers?
iban.supported_scheme?(:SCI) # true
```

When the IBAN is not valid the failed checks are available for inspection:

```rb
iban = client.validations.validate("ES12")
iban.valid? # false
iban.failed_checks
#[#<Ibancom::Resources::IBAN::Check:0x00007f384a576eb0 @code="202", @message="IBAN Check digit not correct", @response=nil, @type=:iban>,
# #<Ibancom::Resources::IBAN::Check:0x00007f384a576de8 @code="205", @message="IBAN structure is not correct", @response=nil, @type=:structure>,
# #<Ibancom::Resources::IBAN::Check:0x00007f384a576cf8 @code="203", @message="IBAN Length is not correct. Spain IBAN must be 24 characters long.", @response=nil, @type=:length>]
```

You can also validate United Kingdom Sort Code and Account Numbers:

```rb
scan = client.validations.validate_scan("200415", "38290008")
scan.valid? # true

# What is the bank/branch associated to this account?
bank = scan.bank # <Ibancom::Resources::SCAN::Bank:0x0000000107c0fc80 ...
bank.bank        # "BARCLAYS BANK UK PLC"
bank.bic         # "BUKBGB22XXX"
bank.branch      # "BARCLAYBANK B'CARD N'PTON"
bank.address     # "Dept AC Barclaycard House "
bank.city        # "Northampton"
bank.zip         # "NN4 7SG"
bank.phone       # "01604 234234"
bank.country     # "GB"

# What payment schemes does it support?
scan.supported_schemes
#[#<Ibancom::Resources::SCAN::Scheme:0x0000000107c0df70 @code=:FPS_PAYMENTS, @response=nil, @supported="YES">,
# #<Ibancom::Resources::SCAN::Scheme:0x0000000107c0def8 @code=:CHAPS, @response=nil, @supported="YES">,
# #<Ibancom::Resources::SCAN::Scheme:0x0000000107c0de80 @code=:BACS, @response=nil, @supported="YES">,
# #<Ibancom::Resources::SCAN::Scheme:0x0000000107c0de08 @code=:CCC_PAYMENTS, @response=nil, @supported="YES">]

# Does the SCAN supports faster payments?
scan.supported_scheme?(:FPS_PAYMENTS) # true
```

In the same way as with the IBAN, when the SCAN is not valid the failed checks are available for inspection:

```rb
scan = client.validations.validate_scan("000001", "00000002")
scan.valid? # false
scan.failed_checks
#[#<Ibancom::Resources::SCAN::Check:0x00000001088debf0 @code="202", @message="Sort Code not found in bank directory",
# @response=nil, @type=:length>]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then tag and push the new version:

```git
git tag vx.x.x main
git push origin vx.x.x
```

The tagging will trigger the GitHub action defined in `release.yml`, pushing the gem to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/devengoapp/ibancom-ruby>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/devengoapp/ibancom-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PFS project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/devengoapp/ibancom-ruby/blob/main/CODE_OF_CONDUCT.md).

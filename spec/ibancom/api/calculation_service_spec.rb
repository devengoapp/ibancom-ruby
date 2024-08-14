# frozen_string_literal: true

RSpec.describe Ibancom::API::CalculationService do
  let(:client) { Ibancom::Client.new(apikey: "test", logger_enabled: false) }

  describe "calculate action" do
    it "builds the correct request" do
      stub_request(:post, %r{/calc-api.php$}).to_return(read_http_fixture("calculations/calculate/success.http"))
      client.calculations.calculate({ country: "GB", bankcode: "012345", account: "01234567" })

      expect(WebMock).to have_requested(:post, %r{/calc-api.php})
        .with(body: "account=01234567&api_key=test&bankcode=012345&country=GB&format=json")
    end
  end
end

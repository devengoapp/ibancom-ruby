# frozen_string_literal: true

RSpec.describe Ibancom::API::ValidationService do
  let(:client) { Ibancom::Client.new(apikey: "test", logger_enabled: false) }
  let(:iban) { client.validations.validate(iban_number) }

  describe "validate action" do
    it "builds the correct request" do
      stub_request(:post, %r{/clients/api/v4/iban/$}).to_return(read_http_fixture("validations/validate/success.http"))
      client.validations.validate("test")

      expect(WebMock).to have_requested(:post, %r{/clients/api/v4/iban/})
        .with(body: "api_key=test&format=json&iban=test&sci=1")
    end

    context "when a valid IBAN is provided" do
      let(:iban_number) { "ES7004878248947469245596" }

      before do
        stub_request(:post, %r{/clients/api/v4/iban/$}).to_return(read_http_fixture("validations/validate/success.http"))
      end

      it "returns a passed validation" do
        expect(iban).to be_a(Ibancom::Resources::IBAN::Validation)
        expect(iban.valid?).to be true
      end

      it "returns bank information" do
        bank = iban.bank

        expect(bank).to be_a(Ibancom::Resources::IBAN::Bank)
        expect(bank.bic).to eq("CAIXESBBXXX")
        expect(bank.country_iso).to eq("ES")
        expect(bank.bank_code).to eq("0487")
        expect(bank.bank).to eq("CAIXABANK S.A.")
      end

      it "returns schemes information" do
        schemes = iban.schemes

        expect(schemes).to be_a(Ibancom::Resources::IBAN::Schemes)
        expect(iban.supported_schemes).not_to be_empty
        expect(iban.supported_scheme?(:SCI)).to be true
      end

      it "returns checks information" do
        checks = iban.checks

        expect(checks).to be_a(Ibancom::Resources::IBAN::Checks)
        expect(iban.failed_checks).to be_empty
      end
    end

    context "when a invalid IBAN is provided" do
      let(:iban_number) { "FAKE" }

      before do
        stub_request(:post, %r{/clients/api/v4/iban/$}).to_return(read_http_fixture("validations/validate/error.http"))
      end

      it "confirms it is invalid" do
        expect(iban).to be_a(Ibancom::Resources::IBAN::Validation)
        expect(iban.valid?).to be false
      end

      it "provides failed checks" do
        checks = iban.checks

        expect(checks).to be_a(Ibancom::Resources::IBAN::Checks)
        expect(iban.failed_checks).not_to be_empty
      end

      it "return false supported scheme" do
        expect(iban.supported_scheme?(:SCI)).to be false
      end
    end
  end
end

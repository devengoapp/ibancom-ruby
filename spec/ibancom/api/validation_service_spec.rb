# frozen_string_literal: true

RSpec.describe Ibancom::API::ValidationService do
  let(:client) { Ibancom::Client.new(apikey: "test", logger_enabled: false) }

  describe "validate action" do
    let(:iban) { client.validations.validate(iban_number) }

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

  describe "validate scan action" do
    let(:scan) { client.validations.validate_scan(sort_code, account_number) }

    it "builds the correct request" do
      stub_request(:post, %r{/clients/api/v4/sort/$}).to_return(read_http_fixture("validations/validate/scan_success.http"))
      client.validations.validate_scan("test_sort_code", "test_account_number")

      expect(WebMock).to have_requested(:post, %r{/clients/api/v4/sort/})
        .with(body: "account=test_account_number&api_key=test&format=json&sortcode=test_sort_code")
    end

    context "when valid sort code and account number is provided" do
      let(:sort_code) { "200415" }
      let(:account_number) { "38290008" }

      before do
        stub_request(:post, %r{/clients/api/v4/sort/$}).to_return(read_http_fixture("validations/validate/scan_success.http"))
      end

      it "returns a passed validation" do
        expect(scan).to be_a(Ibancom::Resources::SCAN::Validation)
        expect(scan.valid?).to be true
      end

      it "returns account information" do
        account = scan.account

        expect(account).to be_a(Ibancom::Resources::SCAN::Account)
        expect(account.sortcode).to eq("200415")
        expect(account.account).to eq("38290008")
        expect(account.iban).to eq("GB46BUKB20041538290008")
      end

      it "returns bank information" do
        bank = scan.bank

        expect(bank).to be_a(Ibancom::Resources::SCAN::Bank)
        expect(bank.bic).to eq("BUKBGB22XXX")
        expect(bank.country).to eq("GB")
        expect(bank.bank).to eq("BARCLAYS BANK UK PLC")
      end

      it "returns schemes information" do
        schemes = scan.schemes

        expect(schemes).to be_a(Ibancom::Resources::SCAN::Schemes)
        expect(scan.supported_schemes).not_to be_empty
        expect(scan.supported_scheme?(:FPS_PAYMENTS)).to be true
      end

      it "returns checks information" do
        checks = scan.checks

        expect(checks).to be_a(Ibancom::Resources::SCAN::Checks)
        expect(scan.failed_checks).to be_empty
      end
    end

    context "when an invalid sort code or account number is provided" do
      let(:sort_code) { "INVALID" }
      let(:account_number) { "38290008" }

      before do
        stub_request(:post, %r{/clients/api/v4/sort/$}).to_return(read_http_fixture("validations/validate/scan_error.http"))
      end

      it "confirms it is invalid" do
        expect(scan).to be_a(Ibancom::Resources::SCAN::Validation)
        expect(scan.valid?).to be false
      end

      it "provides failed checks" do
        checks = scan.checks

        expect(checks).to be_a(Ibancom::Resources::SCAN::Checks)
        expect(scan.failed_checks).not_to be_empty
      end

      it "return false supported scheme" do
        expect(scan.supported_scheme?(:FASTER_PAYMENTS)).to be false
      end
    end
  end
end

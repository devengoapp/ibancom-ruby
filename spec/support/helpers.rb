# frozen_string_literal: true

module RSpecSupportHelpers
  def http_fixture(*names)
    File.join(RSPEC_ROOT, "fixtures", *names)
  end

  def read_http_fixture(*names)
    File.read(http_fixture(*names))
  end
end

RSpec.configure do |config|
  config.include RSpecSupportHelpers
end

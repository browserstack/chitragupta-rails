require "logger"
require "chitragupta"
require "chitragupta/middleware"

RSpec.describe Chitragupta::Middleware do
  let(:app) { lambda { |env| [200, {}, env] } }

  it "clears context inherited from an earlier request on the same thread" do
    Chitragupta.payload = { request_id: "previous" }
    seen = nil
    described_class.new(lambda { |env| seen = Chitragupta.payload.dup; [200, {}, env] }).call({})

    expect(seen).to eq({})
  end

  it "clears context on the way out and returns the app response" do
    Chitragupta.payload = { request_id: "previous" }

    expect(described_class.new(app).call(:env)).to eq([200, {}, :env])
    expect(Chitragupta.payload).to eq({})
  end

  it "clears context when the app raises" do
    failing = lambda { |_env| Chitragupta.payload = { request_id: "current" }; raise "boom" }

    expect { described_class.new(failing).call({}) }.to raise_error("boom")
    expect(Chitragupta.payload).to eq({})
  end
end

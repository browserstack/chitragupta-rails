require "logger"
require "chitragupta"
require "chitragupta/middleware"

RSpec.describe Chitragupta::Middleware do
  it "clears context inherited from an earlier request on the same thread" do
    Chitragupta.payload = { request_id: "previous" }
    seen = nil
    described_class.new(lambda { |env| seen = Chitragupta.payload.dup; [200, {}, env] }).call({})

    expect(seen).to eq({})
  end

  it "keeps the current context until the response body closes" do
    body = Class.new do
      attr_reader :during_each, :during_close

      def each
        @during_each = Chitragupta.payload.dup
        yield "chunk"
      end

      def close
        @during_close = Chitragupta.payload.dup
      end
    end.new
    app = lambda do |_env|
      Chitragupta.payload = { request_id: "current" }
      [200, {}, body]
    end

    response = described_class.new(app).call({})
    expect(response[0, 2]).to eq([200, {}])
    expect(Chitragupta.payload).to eq({ request_id: "current" })

    response[2].each { |_| }
    expect(body.during_each).to eq({ request_id: "current" })

    response[2].close
    expect(body.during_close).to eq({ request_id: "current" })
    expect(Chitragupta.payload).to eq({})
  end

  it "clears context when the app raises" do
    failing = lambda { |_env| Chitragupta.payload = { request_id: "current" }; raise "boom" }

    expect { described_class.new(failing).call({}) }.to raise_error("boom")
    expect(Chitragupta.payload).to eq({})
  end

  it "clears context when closing the response body raises" do
    body = Class.new do
      def each
      end

      def close
        raise "close boom"
      end
    end.new
    app = lambda do |_env|
      Chitragupta.payload = { request_id: "current" }
      [200, {}, body]
    end

    response = described_class.new(app).call({})
    expect { response[2].close }.to raise_error("close boom")
    expect(Chitragupta.payload).to eq({})
  end
end

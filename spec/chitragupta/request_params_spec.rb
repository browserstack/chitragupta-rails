require "json"
require "logger"
require "chitragupta"

RSpec.describe "Chitragupta request params logging" do
  let(:formatter) { Chitragupta::JsonLogFormatter.new }

  before do
    allow(Chitragupta::Util).to receive(:called_as_rails_server?).and_return(true)
  end

  def emitted_params(params)
    Chitragupta.payload = { method: "POST", path: "/login", ip: "1.2.3.4",
                            request_id: "r1", user_id: 1, params: params }
    record = JSON.parse(formatter.call("INFO", Time.now, nil, { status: 200 }))
    record["data"]["request"]["params"]
  end

  it "serializes the hash a rack host supplies" do
    expect(emitted_params({ "user" => "a", "page" => 2 })).to eq('{"user":"a","page":2}')
  end

  it "emits already serialized params exactly once" do
    expect(emitted_params('{"user":"a"}')).to eq('{"user":"a"}')
  end
end

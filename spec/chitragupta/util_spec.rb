RSpec.describe Chitragupta::Util do


  context 'called_as_rails_server?' do

    it 'should return true if Rails Server is initialized' do
      module Rails
        class Server
        end
      end
      expect(Chitragupta::Util.called_as_rails_server?).to eq(true)
    end

  end


  context 'called_as_sidekiq?' do

    it 'should return false if Sidekiq.server? is nil' do
      expect(Sidekiq).to receive(:server?).and_return(nil)
      expect(Chitragupta::Util.called_as_sidekiq?).to eq(false)
    end

    it 'should return true if Sidekiq.server? is "constant"' do
      expect(Sidekiq).to receive(:server?).and_return("constant")
      expect(Chitragupta::Util.called_as_sidekiq?).to eq(true)
    end

  end


  context 'called_as_rake?' do

    it 'should return false if File.basename is not rake' do
      expect(File).to receive(:basename).and_return('')
      expect(Chitragupta::Util.called_as_rake?).to eq(false)
    end

    it 'should return true if File.basename is "rake"' do
      expect(File).to receive(:basename).and_return("rake")
      expect(Chitragupta::Util.called_as_rake?).to eq(true)
    end

  end


  context 'called_as_console?' do

    it 'should return true if Rails Console is initialized' do
      module Rails
        class Console
        end
      end
      expect(Chitragupta::Util.called_as_console?).to eq(true)
    end

  end


  context 'sanitize_keys' do
    let(:initialized_data) { {log: {}, meta: {}} }
    
    before(:each) do
      expect(Chitragupta::Util).to receive(:initialize_data).and_return(initialized_data)
    end
    require 'time'
    timestamp = Time.parse("2021-02-22T18:05:48Z")
    test_cases = [
      {should: "dump string message as is in dynamic_data", params: {log_level: "INFO", timestamp: timestamp, message: "dynamic_data"},
          expected_output: "{\"log\":{\"level\":\"INFO\",\"kind\":null,\"id\":null,\"dynamic_data\":\"dynamic_data\"},\"meta\":{\"timestamp\":\"2021-02-22T18:05:48Z\",\"team\":null,\"component\":null,\"application\":null}}\n"},
      {should: "parse contents of message hash", params: {log_level: "INFO", timestamp: timestamp, message: {log: {kind: "TEST", id: "123", dynamic_data: "ASD"}}},
          expected_output: "{\"log\":{\"level\":\"INFO\",\"kind\":\"TEST\",\"id\":\"123\",\"dynamic_data\":\"ASD\"},\"meta\":{\"timestamp\":\"2021-02-22T18:05:48Z\",\"team\":null,\"component\":null,\"application\":null}}\n"},
      {should: "ignore improperly nested kind in message", params: {log_level: "INFO", timestamp: timestamp, message: {kind: "IGNORED_KIND"}},
          expected_output: "{\"log\":{\"level\":\"INFO\",\"kind\":null,\"id\":null,\"dynamic_data\":null},\"meta\":{\"timestamp\":\"2021-02-22T18:05:48Z\",\"team\":null,\"component\":null,\"application\":null}}\n"},
      {should: "dump inspected message object", params: {log_level: "INFO", timestamp: timestamp, message: true},
          expected_output: "{\"log\":{\"level\":\"INFO\",\"kind\":null,\"id\":null,\"dynamic_data\":\"true\"},\"meta\":{\"timestamp\":\"2021-02-22T18:05:48Z\",\"team\":null,\"component\":null,\"application\":null}}\n"}]

    test_cases.each do |t|
      it "should #{t[:should]}" do
        expect(Chitragupta::Util.sanitize_keys(t[:params][:log_level], t[:params][:timestamp], t[:params][:message])).to eq(t[:expected_output])
      end
    end

  end


  context 'populate_server_data' do

    before(:each) do
      Chitragupta.payload = {method: "GET", path: "/", controller: "TestController", action: "dummy", ip: "127.0.0.1", request_id: "123asd", user_id: 1, params: {a: 1}}
    end

    it 'should populate all the required key values for server request and nil for missing message values' do
      data = {data: {}, meta: {format: {}}}
      expected_output = {
          data: {
              request: {
                  method: "GET",
                  endpoint: "/",
                  controller: "TestController",
                  action: "dummy",
                  ip: "127.0.0.1",
                  id: "123asd",
                  user_id: 1,
                  params: '{"a":1}',
              },
              response: {
                  status: nil,
                  duration: nil,
                  view_rendering_duration: nil,
                  db_query_duration: nil
              }
          },
          meta: {
              format: {
                  category: "server"
              }
          }
      }
      Chitragupta::Util.send(:populate_server_data, data, nil)
      expect(data).to eq(expected_output)
    end

    it 'should populate all the required key values for server request and response' do
      data = {data: {}, meta: {format: {}}}
      expected_output = {
          data: {
              request: {
                  method: "GET",
                  endpoint: "/",
                  controller: "TestController",
                  action: "dummy",
                  ip: "127.0.0.1",
                  id: "123asd",
                  user_id: 1,
                  params: '{"a":1}',
              },
              response: {
                  status: 200,
                  duration: 10.01,
                  view_rendering_duration: 12.34,
                  db_query_duration: 0.09
              }
          },
          meta: {
              format: {
                  category: "server"
              }
          }
      }
      message = {
          status: 200,
          duration: 10.01,
          view: 12.34,
          db: 0.09
      }
      Chitragupta::Util.send(:populate_server_data, data, message)
      expect(data).to eq(expected_output)
    end

  end


  context 'populate_task_data' do

    it 'should populate process related details' do
      expect(Rake.application).to receive(:current_task).and_return("abc:testing_rake")
      expect(Rake.application).to receive(:execution_id).and_return("124asd")

      data = {data: {}, meta: {format: {}}}
      Chitragupta::Util.send(:populate_task_data, data, nil)
      expect(data).to eq({
          data: {
              name: "abc:testing_rake",
              execution_id: "124asd"
          },
          meta: {
              format: {
                  category: "process"
              }
          }
      })
    end

  end


  pending 'populate_bg_worker_data'


  context 'initialize_data' do

    it 'should create common keys and add call populate_server_data if called_as_rails_server? returns true' do
      expect(Chitragupta::Util).to receive(:called_as_rails_server?).and_return(true)
      expect(Chitragupta::Util).to receive(:populate_server_data).once
      expect(Chitragupta::Util.send(:initialize_data, nil)).to eq({log: {}, meta: {:format=>{}}, :data=>{}})
    end

    it 'should create common keys and add call populate_task_data if called_as_rake? returns true' do
      expect(Chitragupta::Util).to receive(:called_as_rails_server?).and_return(false)
      expect(Chitragupta::Util).to receive(:called_as_rake?).and_return(true)
      expect(Chitragupta::Util).to receive(:populate_task_data).once
      expect(Chitragupta::Util.send(:initialize_data, nil)).to eq({log: {}, meta: {:format=>{}}, :data=>{}})
    end

    it 'should create common keys and add call populate_bg_worker_data if called_as_sidekiq? returns true' do
      expect(Chitragupta::Util).to receive(:called_as_rails_server?).and_return(false)
      expect(Chitragupta::Util).to receive(:called_as_rake?).and_return(false)
      expect(Chitragupta::Util).to receive(:called_as_sidekiq?).and_return(true)
      expect(Chitragupta::Util).to receive(:populate_bg_worker_data).once
      expect(Chitragupta::Util.send(:initialize_data, nil)).to eq({log: {}, meta: {:format=>{}}, :data=>{}})
    end

  end

end

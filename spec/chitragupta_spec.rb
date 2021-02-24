RSpec.describe Chitragupta do

  context 'get_unique_log_id' do

    it "should return unique strings" do
      string1 = Chitragupta.get_unique_log_id
      string2 = Chitragupta.get_unique_log_id
      expect(string1).to_not eq(string2)
    end
  end


  context 'setup_application_logger' do

    context 'for rails server' do

      before(:each) do
        # Need to require this as rspec can not require dynamically inside the if block
        require "chitragupta/active_support/instrumentation"
        expect(Chitragupta::Util).to receive(:called_as_rake?).and_return(false)
        expect(Chitragupta::Util).to receive(:called_as_sidekiq?).and_return(false)
        expect(Chitragupta).to receive(:configure_app).once
      end

      after(:each) do
        Chitragupta.setup_application_logger(nil, nil)
      end

      it 'should call the current_user_caller of ActionController::Instrumentation' do
        expect(Chitragupta::Util).to receive(:called_as_rails_server?).and_return(true)
        expect(ActionController::Instrumentation).to receive(:current_user_caller=).once
        expect(ActiveSupport::Notifications).to receive(:subscribe).once
      end

      it 'should not call the current_user_caller of ActionController::Instrumentation' do
        expect(Chitragupta::Util).to receive(:called_as_rails_server?).and_return(false)
        expect(ActionController::Instrumentation).to_not receive(:current_user_caller=)
        expect(ActiveSupport::Notifications).to_not receive(:subscribe)
      end
    end

    context 'for sidekiq server' do

      before(:each) do
        expect(Chitragupta::Util).to receive(:called_as_rails_server?).and_return(false)
        expect(Chitragupta::Util).to receive(:called_as_rake?).and_return(false)
        expect(Chitragupta).to receive(:configure_app).once
      end

      after(:each) do
        Chitragupta.setup_application_logger(nil, nil)
      end

      it 'should set the Sidekiq.logger.formatter' do
        expect(Chitragupta::Util).to receive(:called_as_sidekiq?).and_return(true)
        expect(Sidekiq.logger).to receive(:formatter=).once
      end

      it 'should not set the Sidekiq.logger.formatter' do
        expect(Chitragupta::Util).to receive(:called_as_sidekiq?).and_return(false)
        expect(Sidekiq.logger).to_not receive(:formatter=)
      end

    end
  end


  context 'configure_app' do

    it 'should do call configure on the Application class' do
      module App
        class Application
          attr_accessor :config
          def self.configure(&block)
          end
        end
      end
      expect(App::Application).to receive(:configure)
      Chitragupta.send(:configure_app, App)
    end

  end

end

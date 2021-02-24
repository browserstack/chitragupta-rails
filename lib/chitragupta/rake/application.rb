require 'rake'
module Rake
  class Application
    attr_accessor :current_task, :execution_id
  end
end

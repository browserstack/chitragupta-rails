require "chitragupta/rake/application"

module Rake
  class Task
    alias :old_execute :execute 
    def execute(args=nil)
      Rake.application.current_task = @name
      Rake.application.execution_id = Chitragupta.get_unique_log_id
      old_execute(args)
    end
  end
end

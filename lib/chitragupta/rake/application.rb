require 'rake'
module Rake
  class Application
    def current_task
      Thread.current[:chitragupta_rake_current_task]
    end

    def current_task=(task)
      Thread.current[:chitragupta_rake_current_task] = task
    end

    def execution_id
      Thread.current[:chitragupta_rake_execution_id]
    end

    def execution_id=(id)
      Thread.current[:chitragupta_rake_execution_id] = id
    end
  end
end

require 'rake'
module Rake
  class Application
    # Threads spawned inside a task have no context of their own, so they read
    # the last context set by the application.
    def current_task
      Thread.current[:chitragupta_rake_current_task] || @current_task
    end

    def current_task=(task)
      @current_task = task
      Thread.current[:chitragupta_rake_current_task] = task
    end

    def execution_id
      Thread.current[:chitragupta_rake_execution_id] || @execution_id
    end

    def execution_id=(id)
      @execution_id = id
      Thread.current[:chitragupta_rake_execution_id] = id
    end
  end
end

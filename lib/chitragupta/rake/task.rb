require "chitragupta/rake/application"

module Chitragupta
  module RakeTask
    def execute(args=nil)
      depth = Thread.current[:chitragupta_rake_context_depth] || 0
      previous_task = Rake.application.current_task
      previous_execution_id = Rake.application.execution_id
      Thread.current[:chitragupta_rake_context_depth] = depth + 1
      Rake.application.current_task = @name
      Rake.application.execution_id = Chitragupta.get_unique_log_id
      super
    ensure
      Thread.current[:chitragupta_rake_context_depth] = depth
      # Only nested tasks restore: hosts read current_task after a top-level invoke returns.
      if depth > 0
        Rake.application.current_task = previous_task
        Rake.application.execution_id = previous_execution_id
      end
    end
  end
end

Rake::Task.prepend(Chitragupta::RakeTask)

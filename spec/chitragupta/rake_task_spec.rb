require "logger"
require "chitragupta"
require "rake"
require "chitragupta/rake/task"

RSpec.describe "Chitragupta Rake task context" do
  around do |example|
    application = Rake.application
    Rake.application = Rake::Application.new
    example.run
  ensure
    Rake.application = application
  end

  it "preserves the completed top-level task context" do
    Rake::Task.define_task(:top_level)

    Rake::Task[:top_level].invoke

    expect(Rake.application.current_task).to eq("top_level")
    expect(Rake.application.execution_id).not_to be_nil
  end

  it "restores the outer task context after a nested task" do
    contexts = []
    Rake::Task.define_task(:inner) do
      contexts << [Rake.application.current_task, Rake.application.execution_id]
    end
    Rake::Task.define_task(:outer) do
      contexts << [Rake.application.current_task, Rake.application.execution_id]
      Rake::Task[:inner].invoke
      contexts << [Rake.application.current_task, Rake.application.execution_id]
    end

    Rake::Task[:outer].invoke

    expect(contexts.map(&:first)).to eq(%w[outer inner outer])
    expect(contexts[0].last).to eq(contexts[2].last)
    expect(contexts[0].last).not_to eq(contexts[1].last)
  end

  it "restores the outer task context when a nested task fails" do
    context = nil
    Rake::Task.define_task(:failing_inner) { raise "failure" }
    Rake::Task.define_task(:rescuing_outer) do
      begin
        Rake::Task[:failing_inner].invoke
      rescue RuntimeError
        context = [Rake.application.current_task, Rake.application.execution_id]
      end
    end

    Rake::Task[:rescuing_outer].invoke

    expect(context.first).to eq("rescuing_outer")
    expect(context.last).to eq(Rake.application.execution_id)
  end

  it "keeps task attribution in threads the task spawns" do
    context = nil
    Rake::Task.define_task(:spawns_thread) do
      Thread.new do
        context = [Rake.application.current_task, Rake.application.execution_id]
      end.join
    end

    Rake::Task[:spawns_thread].invoke

    expect(context).to eq(["spawns_thread", Rake.application.execution_id])
  end

  it "isolates concurrently executing tasks" do
    ready = Queue.new
    release = Queue.new
    contexts = Queue.new
    %i[first second].each do |name|
      Rake::Task.define_task(name) do
        ready << true
        release.pop
        contexts << [name.to_s, Rake.application.current_task, Rake.application.execution_id]
      end
    end
    Rake::MultiTask.define_task(all: %i[first second])

    execution = Thread.new { Rake::Task[:all].invoke }
    2.times { ready.pop }
    2.times { release << true }
    execution.join
    results = 2.times.map { contexts.pop }.sort

    expect(results.map { |expected, actual, _id| [expected, actual] }).to eq([
      %w[first first],
      %w[second second]
    ])
    expect(results.map(&:last).uniq.length).to eq(2)
  end
end

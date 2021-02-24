module ActiveSupport
  module TaggedLogging
    module Formatter

      def call(severity, timestamp, progname, msg)
        # original call: super(severity, timestamp, progname, "#{tags_text}#{msg}")
        # changed to below to avoid conversion of the objects into string and to avoid all the tags from being called
        super(severity, timestamp, progname, msg)
      end

    end
  end
end

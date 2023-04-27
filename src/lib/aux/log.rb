module Aux
  class Log
    class << self
      def info(message)
        logger.info(message)
      end

      def error(message)
        logger.error(message)
      end

      def logger
        @info_logger ||= Logger.new(STDOUT)
      end
    end
  end
end

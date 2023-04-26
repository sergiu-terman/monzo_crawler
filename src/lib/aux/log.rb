module Aux
  class Log
    class << self
      def info(message)
        info_logger.info(message)
      end

      def error(message)
        err_logger.error(message)
      end

      def info_logger
        @info_logger ||= Logger.new(STDOUT)
      end

      def err_logger
        l = Logger.new(Pathname.new("#{ENV['WORKDIR']}/storage/err.log"))
        l.level = Logger::ERROR
        @err_logger = l
      end
    end
  end
end

module Task
  class Executor

    def initialize(role, initial_tasks=[], pool_size=1)
      @role = role
      @pool = Thread.pool(pool_size)
      @q = Queue.new(initial_tasks)
    end

    def run
      internal_run
      self
    end

    def wait
      unless @run_thread.nil?
        @run_thread.join
      end
      @pool.shutdown
    end

    def push(task)
      @q.push(task)
      self
    end

    private

    def internal_run
      @run_thread ||= Thread.new do
        loop do
          if @q.empty?
            sleep 0.2
            Aux::Log.info("No jobs found for #{@role}, waiting for a while")
            next
          end

          task = @q.pop

          # a sentinel value to stop processing the queue
          if task == :done
            break
          end

          @pool.process{ task.run }
        end
      end
    end
  end
end

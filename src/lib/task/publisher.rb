module Task
  class Publisher

    def initialize(task_class, executor)
      @task_class = task_class
      @executor = executor
    end

    def next_publisher=(publisher)
      @next_publisher = publisher
    end

    def publish(page)
      task = @task_class.new(page, @next_publisher)
      @executor.push(task)
    end
  end
end

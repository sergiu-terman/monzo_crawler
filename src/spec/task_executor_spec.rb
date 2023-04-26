describe "Task::Executor" do
  before do
    @task1 = double("task_1")
    @task2 = double("task_2")
  end

  it "runs the initial tasks" do
    expect(@task1).to receive(:run)
    expect(@task2).to receive(:run)

    Task::Executor.new("test", [@task1, @task2, :done]).run.wait
  end

  it "runs the tasks that are later pushed in the queue" do
    expect(@task1).to receive(:run)
    expect(@task2).to receive(:run)

    Task::Executor.new("test", [@task1]).run
      .push(@task2)
      .push(:done)
      .wait
  end

  it "waits for all the threads in the pool to finish the job" do
    class Sleepy
      def run
        sleep(0.05)
      end
    end

    start_t = Time.now
    Task::Executor.new("test", [Sleepy.new, :done]).run.wait
    end_t = Time.now

    # checks that the execution time is more than 50 milliseconds
    expect(end_t - start_t).to be > 0.05
  end
end

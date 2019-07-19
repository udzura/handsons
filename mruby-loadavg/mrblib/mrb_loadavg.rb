class Loadavg
  def self.open
    self.new
  end

  def initialize
    f = File.open("/proc/loadavg", "r")
    data = f.read.chomp.split
    f.close

    @avg_over_1min = data[0].to_f
    @avg_over_5min = data[1].to_f
    @avg_over_15min = data[2].to_f
    @runnable_tasks = data[3].split('/')[0].to_i
    @existing_tasks = data[3].split('/')[1].to_i
    @last_created_pid = data[4].to_i
  end
  attr_reader :avg_over_1min,
              :avg_over_5min,
              :avg_over_15min,
              :runnable_tasks,
              :existing_tasks,
              :last_created_pid
end

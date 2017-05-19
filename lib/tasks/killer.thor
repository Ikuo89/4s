require 'thor/rails'
require './config/environment'

class Killer < Thor
  desc 'kill', 'process killer'
  def kill(name = '*')
    files = Dir[File.expand_path('../../../', __FILE__) + "/tmp/pids/#{name}.lock"]
    files.each do |file_name|
      next unless FileTest.file?(file_name)

      pid = File.read(file_name, :encoding => Encoding::UTF_8)
      pid = pid.gsub("\n", "").to_i

      gid = nil
      begin
        gid = Process.getpgid(pid)
      rescue
      end
      if gid != nil
        command = "kill -KILL `ps ho pid --ppid=#{pid}`"
        puts command
        %x(#{command})

        puts "kill -KILL #{pid}"
        Process.kill('KILL', pid)
      else
        puts "pid[#{pid}] not exists"
      end
    end
  end
end

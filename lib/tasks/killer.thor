require 'thor/rails'
require './config/environment'

class Killer < Thor
  desc 'killer', 'process killer'
  def killer
    files = Dir[Rails.root.join('tmp', 'pids', '*.lock')]
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

    command = "rm -rf #{tmp_dir}/*"
    puts command
    %x(#{command})
  end
end

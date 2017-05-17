class BatchSerializer
  class << self
    def run(suffix = '')
      caller_name = caller[0][/\/([^\/]*)\.[^\.]*:/, 1] + suffix
      file_path = lock_file_path(caller_name)
      File.open(file_path, 'w') do |lock_file|
        if lock_file.flock(File::LOCK_EX|File::LOCK_NB)
          lock_file.puts(Process.pid)
          begin
            yield
          rescue => e
            Rails.logger.error e
          ensure
            File.delete(file_path)
          end
        else
          raise Locked
        end
      end
    end

    def lock_file_path(calller_name)
      Rails.root.join('tmp', 'pids', "#{calller_name}.lock")
    end
  end
end

class Locked < StandardError
end

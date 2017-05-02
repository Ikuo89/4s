# config valid only for current version of Capistrano
lock "3.8.0"

set :application, "4s"
set :repo_url, "git@github.com:Ikuo89/schedule-management.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/4s"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml", "config/settings.yml", "config/puma.rb"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "node_modules"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :puma_default_hooks, false
set :puma_preload_app, false
set :prune_bundler, true

namespace :deploy do
  task :build_angular do
    on roles(:web) do
      execute "cd #{release_path};npm run build"
    end
  end

  after 'npm:install', 'deploy:build_angular'
end

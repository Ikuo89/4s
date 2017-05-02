set :staging, :production
set :branch, :master

role :job, %w{ec2-user@13.113.152.25}
role :app, %w{ec2-user@13.113.152.25}
role :web, %w{ec2-user@13.113.152.25}
role :db, %w{ec2-user@13.113.152.25}

set :ssh_options, {
  keys: %w(~/.ssh/ih.pem),
  forward_agent: true,
  auth_methods: %w(publickey)
}

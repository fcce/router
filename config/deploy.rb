require 'mina/rvm'
require 'mina/slack'



set :repository, 'git@github.com:rongchang/router.git'
set :branch, 'master'

set :term_mode, nil

set :shared_paths, ['config/redis_config.lua','log', 'backup']

# Optional settings:
set :user, 'ubuntu'    # Username in the server to SSH to.
set :port, '52087'     # SSH port number.
set :identity_file, '../key/id_rsa'
# set :bundle_bin, "/home/ubuntu/.rvm/gems/ruby-2.1.2/bin/bundle"
set :rvm_path, '/home/ubuntu/.rvm/bin/rvm'

case ENV['to']
  when 'test'
    set :domain, '115.159.23.93'
    set :deploy_to, '/data/router'
  # set :branch, 'f233'
  when 'production'
    set :domain, '115.159.73.75'
    set :deploy_to, '/data/router'
    # set :slack_url, "https://hooks.slack.com/services/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"
    # set :slack_room, "#mina_deployment"
    # set :slack_application, 'router'
  else
    p "Please set which environment to be deployed"
end

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.1.2p95@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/backup"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/backup"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/redis_config.lua"]
  queue  %[echo "-----> Be sure to edit '/shared/config/redis_config.lua'."]

end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do


    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'

    to :launch do

    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers


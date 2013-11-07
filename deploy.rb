#! /usr/bin/env ruby

require "optparse"

class Deployer
  attr_accessor :branch, :server, :include_tests

  def deploy
    instances = create_instances
    instances.each do |instance|
      instance.create_deploy_directory
      instance.set_last_release
      instance.push_apps
      instance.push_tests
      instance.setup_apogee(@include_tests)
    end
    instances.each do |instance|
      instance.set_current
      instance.run_services
      instance.prune_releases
    end
  end

  def create_instances
    create_ec2_instances
  end

  def create_ec2_instances
    if server
      [EC2Instance.new(server)]
    elsif branch == "origin/master"
      [EC2Instance.new("madeye.io")]
    elsif branch == "origin/develop"
      [EC2Instance.new("staging.madeye.io")]
    else
      #TODO: Make this message more informative for server cases.
      abort "EXITING Do not know where to deploy branch '#{branch}'"
    end
  end

  class Instance < Struct.new(:hostname, :instance_id)
    def deploy_directory
      #name the directory something like 2012_12_09_00_04_26__0800
      @deploy_directory ||= "deploy-#{Time.new.to_s.gsub(/[ :-]/, "_")}"
    end

    def create_deploy_directory
      cmd "mkdir #{deploy_directory}"
    end

    def cmd(command, ignore_failure=false)
      remote_cmd = "ssh #{user}@#{hostname} \"#{command}\""
      puts "RUNNING #{remote_cmd}"
      result = `#{remote_cmd}`
      if $?.exitstatus != 0
        abort "FAILURE RUNNING #{remote_cmd}" unless ignore_failure
      end
      return result
    end

    def local_cmd(command)
      result = `#{command}`
      abort "FAILURE RUNNING #{command}" if $?.exitstatus != 0
      return result
    end

    def push_apps
      ["bolide", "azkaban", "apogee"].each {|app| push_app(app)}
    end

    def push_app(app)
      puts "running rsync -avz #{app} #{user}@#{hostname}:#{deploy_directory}/"
      local_cmd "rsync -avz #{app} #{user}@#{hostname}:#{deploy_directory}/"
      cmd "cd #{deploy_directory}/#{app} && bin/install --production" unless app == "apogee"
      cmd "cd #{deploy_directory}/#{app} && mrt install" if app == "apogee"
    end

    def push_tests
      local_cmd "rsync -avz tests/ #{user}@#{hostname}:#{deploy_directory}/tests/"
    end

    def setup_apogee(include_tests=false)
      tarfile = '/tmp/apogee.tar.gz'
      if include_tests
        test_tarfile = '/tmp/apogee_test.tar.gz'
      end
      puts cmd "sudo rsync -rc #{deploy_directory}/apogee/public/ /var/www/"
      puts cmd "cd #{deploy_directory}/apogee && meteor bundle #{tarfile}"
      puts cmd "cd #{deploy_directory} && tar -xf #{tarfile}"
      #TODO should probably specify a specific version, why is this even necessary
      puts cmd "cd #{deploy_directory}/bundle/server && npm install fibers@1.0.1"
      cmd "rm #{tarfile}"
      if include_tests
        puts cmd "cd #{deploy_directory}/apogee && ln -s ../tests/web zTests && export METEOR_MOCHA_TEST=true && meteor bundle #{test_tarfile}"
        puts cmd "cd /tmp && tar -xf #{test_tarfile} && mv /tmp/bundle /home/ubuntu/#{deploy_directory}/bundle-test"
      end
    end

    def set_current
      cmd "rm -f current-deploy"
      puts cmd "ln -s #{deploy_directory} current-deploy"
    end

    def set_last_release
      cmd "rm -f last-deploy"
      puts cmd "ln -s #{deploy_directory} last-deploy"      
    end

    def prune_releases
      number_to_keep = 8
      releases = cmd("ls -1dt deploy-*").split("\n")
      return if releases.length <= number_to_keep
      cmd "rm -r #{releases[number_to_keep..-1].join ' '}"
    end

    def run_services
      cmd "sudo stop azkaban", true
      cmd "sudo stop bolide", true
      cmd "sudo stop apogee", true

      cmd "sudo start azkaban"
      cmd "sudo start bolide"
      cmd "sudo start apogee"
    end
  end

  class EC2Instance < Instance
    def user
      "ubuntu"
    end
  end
end

#this block is only called when the program is invoked from the command line
if /deploy\.rb/ =~ $PROGRAM_NAME
  deployer = Deployer.new
  OptionParser.new do |opts|
    opts.banner = "Usage: deploy.rb [options]"
#    opts.on("-v", "--verbose", "Verbose output") {|v| deployer.verbose = true}
    opts.on("--include-tests", "Include test apps for meteor-mocha tests") {|v| deployer.include_tests = true}
    opts.on("--server [SERVER]", "Specify Server", String, "Server to deploy to") {|server| deployer.server = server}
    opts.on("--branch [BRANCH]", String, "Branch being deployed (developer branch -> staging, master -> prod)") {|branch| deployer.branch = branch}
  end.parse!
  deployer.deploy
end

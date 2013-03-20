#! /usr/bin/env ruby

require "optparse"
require "vagrant"

class Deployer
  attr_accessor :is_ec2, :is_vagrant, :branch, :server

  def deploy
    instances = create_instances
    instances.each do |instance|
      instance.create_deploy_directory
      instance.set_last_release
      instance.push_apps
      instance.setup_apogee
    end
    instances.each do |instance|
      instance.set_current
      instance.run_services
      instance.prune_releases
    end
  end

  def create_instances
    if is_vagrant
      create_vagrant_instances
    elsif is_ec2
      create_ec2_instances
    end
  end

  def create_vagrant_instances
    puts "creating vagrant instances"
    env = Vagrant::Environment.new
    env.cli("up")
    [VagrantInstance.new("192.168.1.11")]
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
      zippedApp = "#{app}.zip"
      local_cmd "zip -r #{zippedApp} #{app}"
      puts "running scp #{zippedApp} #{user}@#{hostname}:#{deploy_directory}"
      local_cmd "scp #{zippedApp} #{user}@#{hostname}:#{deploy_directory}"
      cmd "cd #{deploy_directory} && unzip #{zippedApp}"
      local_cmd "rm #{zippedApp}"
      cmd "rm #{deploy_directory}/#{zippedApp}"
      cmd "cd #{deploy_directory}/#{app} && npm install -q --production .madeye-common" if app == "azkaban" or app == "bolide"
      cmd "cd #{deploy_directory}/#{app} && npm install -q --production" unless app == "apogee"
    end

    def setup_apogee
      puts cmd "cd #{deploy_directory}/apogee && mrt bundle /tmp/apogee.tar.gz"
      #HACK: Terrible hack.  but the first time we run it it cleans some things up.
      puts cmd "cd #{deploy_directory}/apogee && mrt bundle /tmp/apogee.tar.gz"
      puts cmd "cd #{deploy_directory} && tar -xf /tmp/apogee.tar.gz"
      cmd "rm /tmp/apogee.tar.gz"
    end

    def set_current
      cmd "rm current-deploy || echo \"No current-deploy dir.\""
      puts cmd "ln -s #{deploy_directory} current-deploy"
    end

    def set_last_release
      cmd "rm last-deploy || echo \"No last deploy directory\""
      puts cmd "ln -s #{deploy_directory} last-deploy"      
    end

    def prune_releases
      number_to_keep = 10
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

  class VagrantInstance < Instance
    def user
      "vagrant"
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
    opts.on("--vagrant", "Use Vagrant") {|v| deployer.is_vagrant = true}
    opts.on("--ec2", "Use EC2") {|v| deployer.is_ec2 = true}
    opts.on("--server [SERVER]", "Specify Server", String, "Server to deploy to") {|server| deployer.server = server}
    opts.on("--branch [BRANCH]", String, "Branch being deployed (developer branch -> staging, master -> prod)") {|branch| deployer.branch = branch}
    opts.on("--reset", "(Vagrant only) destroy previous vagrant instances") do |v|
      deployer.is_ec2 = true
    end
    if deployer.is_ec2 and deployer.is_vagrant
      abort("Cannot choose ec2 and vagrant")
    end
  end.parse!
  deployer.deploy
end

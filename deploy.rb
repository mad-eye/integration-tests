#! /usr/bin/env ruby

require "optparse"
require "vagrant"

class Deployer
  attr_accessor :is_ec2, :is_vagrant, :branch

  def deploy
    instances = create_instances
    instances.each do |instance|
      instance.create_deploy_directory
      instance.add_projects
      instance.push_apogee
    end
    instances.each do |instance|
      instance.set_current
      instance.run_services
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
    if branch == "master"
      [EC2Instance.new("madeye.io")]
    elsif branch == "develop"
      [EC2Instance.new("staging.madeye.io")]
    else
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

    def add_projects
      cmd "git clone git@github.com:mad-eye/integration-tests.git #{deploy_directory}"
      cmd "cd #{deploy_directory} && npm install"
    end

    def cmd(command)
      puts "RUNNING ssh #{user}@#{hostname} \"#{command}\""
      `ssh #{user}@#{hostname} "#{command}"`
    end

    #probably should delete this..
    def push_module(node_module)
      #TODO don't understand why madeye-common isn't being picked up here..
      if node_module == "azkaban"
        Dir.chdir("node_modules/#{node_module}") {`npm install madeye-common`}
      end
      `zip -r #{node_module}.zip node_modules/#{node_module}`
      zipped_module = "#{node_module}.zip"
      puts "running scp #{zipped_module} #{user}@#{hostname}:#{deploy_directory}"
      `scp #{zipped_module} #{user}@#{hostname}:#{deploy_directory}`
      cmd "cd #{deploy_directory} && unzip #{zipped_module}"
      `rm #{zipped_module}`
      cmd "rm #{deploy_directory}/#{zipped_module}"
    end

    def push_apogee
      puts cmd "cd #{deploy_directory}/node_modules/apogee && mrt bundle /tmp/apogee.tar.gz"
      puts cmd "cd #{deploy_directory} && tar -xf /tmp/apogee.tar.gz"
      cmd "rm /tmp/apogee.tar.gz"
    end

    def set_current
      cmd "rm current-deploy"
      puts cmd "ln -s #{deploy_directory} current-deploy"
    end

    def run_services
      cmd "sudo stop azkaban"
      cmd "sudo stop bolide"
      cmd "sudo stop apogee"

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

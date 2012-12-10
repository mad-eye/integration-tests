#! /usr/bin/env ruby

require "optparse"
require "vagrant"

class Deployer
  attr_accessor :is_ec2, :is_vagrant

  def deploy
    `npm install`
    instances = create_instances
    instances.each do |instance|
      instance.create_deploy_directory
      instance.push_module "azkaban"
      instance.push_module "bolide"
      instance.push_apogee
    end
    instances.each do |instance|
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
    [EC2Instance.new("10.212.77.213")]
  end

  class Instance < Struct.new(:hostname, :instance_id)
    def deploy_directory
      #name the directory something like 2012_12_09_00_04_26__0800
      @deploy_directory ||= "deploy-#{Time.new.to_s.gsub(/[ :-]/, "_")}"
    end

    def create_deploy_directory
      cmd "mkdir #{deploy_directory}"
    end

    def cmd(command)
      puts "RUNNING ssh #{user}@#{hostname} \"#{command}\""
      `ssh #{user}@#{hostname} "#{command}"`
    end

    def push_module(node_module)
      `zip -r #{node_module}.zip node_modules/#{node_module}`
      zipped_module = "#{node_module}.zip"
      puts "running scp #{zipped_module} #{user}@#{hostname}:#{deploy_directory}"
      `scp #{zipped_module} #{user}@#{hostname}:#{deploy_directory}`
      cmd "cd #{deploy_directory} && unzip #{zipped_module}"
      `rm #{zipped_module}`
      cmd "rm #{deploy_directory}/#{zipped_module}"
    end

    def push_apogee
      #create meteor bundle
      Dir.chdir("node_modules/apogee") do
        results = `mrt bundle /tmp/apogee.tar.gz`
        puts "results are #{results}"
      end
      `scp /tmp/apogee.tar.gz #{user}@#{hostname}:#{deploy_directory}`
      cmd "cd #{deploy_directory} && tar -xf apogee.tar.gz"
      cmd "rm #{deploy_directory}/apogee.tar.gz"
    end

    def run_services
      puts "running services"
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

#this bock is only called when the progrma is invoked from the command line
if /deploy\.rb/ =~ $PROGRAM_NAME 
  deployer = Deployer.new
  OptionParser.new do |opts|
    opts.banner = "Usage: deploy.rb [options]"
#    opts.on("-v", "--verbose", "Verbose output") {|v| deployer.verbose = true}
    opts.on("--vagrant", "Use Vagrant") {|v| deployer.is_vagrant = true}
    opts.on("--ec2", "Use EC2") {|v| deployer.is_ec2 = true}
    opts.on("--reset", "(Vagrant only) destroy previous vagrant instances") do |v|
      deployer.is_ec2 = true
    end
    if deployer.is_ec2 and deployer.is_vagrant
      abort("Cannot choose ec2 and vagrant")
    end
  end.parse!
  deployer.deploy
end

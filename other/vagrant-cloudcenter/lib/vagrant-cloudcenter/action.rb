require "pathname"

require "vagrant/action/builder"
require_relative "action/deploy"
require_relative "action/read_state"

module VagrantPlugins
  module Cloudcenter
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :Deploy, action_root.join("deploy")
      autoload :IsCreated, action_root.join("is_created")
      autoload :IsStopped, action_root.join("is_stopped")
      autoload :MessageAlreadyCreated, action_root.join("message_already_created")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :PackageInstance, action_root.join("package_instance")
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :ReadState, action_root.join("read_state")
      autoload :RunInstance, action_root.join("run_instance")
      autoload :StartInstance, action_root.join("start_instance")
      autoload :StopInstance, action_root.join("stop_instance")
      autoload :TerminateInstance, action_root.join("terminate_instance")
      autoload :TimedProvision, action_root.join("timed_provision") # some plugins now expect this action to exist
      autoload :WaitForState, action_root.join("wait_for_state")
      autoload :WarnNetworks, action_root.join("warn_networks")

      def self.action_prepare_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use Provision
          b.use SyncedFolders
        end
      end

      # This action is called to destroy the remote machine.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, DestroyConfirm do |env, b1|
            if env[:result]
              b1.use ConfigValidate
              b1.use Call, IsCreated do |env, b2|
                if env[:result] != :created
                  env[:ui].info(I18n.t("cloudcenter.not_created"))
                else
                  b2.use TerminateInstance
                end
              end
            else
              env[:ui].info(I18n.t("cloudcenter.will_not_destroy", name: env[:machine].name))
            end

          end
        end
      end

      # This action is called to halt the remote machine.
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            if env[:result] != :created
              env[:ui].info(I18n.t("cloudcenter.not_created"))
            else
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result] != :stopped
                  env2[:ui].info(I18n.t("cloudcenter.stopping"))
                  b2.use StopInstance 
                else
                    env2[:ui].info(I18n.t("cloudcenter.already_stopped"))
                end
              end
            end
          end
        end
      end

      # This action is called to resume the remote machine.
      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            if env[:result] != :created
              env[:ui].info(I18n.t("cloudcenter.not_created"))
            else
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result] == :stopped
                  env2[:ui].info(I18n.t("cloudcenter.starting"))
                  b2.use action_prepare_boot
                  b2.use StartInstance 
                else
                    env2[:ui].info(I18n.t("cloudcenter.already_running"))
                end
              end
            end
          end
        end
      end


      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ReadSSHInfo
        end
      end

      # This action is called to SSH into the machine.
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate

          b.use Call, IsCreated do |env, b2|

            if env[:result] != :created
              env[:ui].info(I18n.t("cloudcenter.not_created"))
            else
              b2.use ReadSSHInfo
              b2.use SSHExec
            end
            
          end
        end
      end

	  # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ReadState
        end
      end
      
      # This action is called to bring the box up from nothing.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBox
          b.use ConfigValidate
          b.use BoxCheckOutdated
          b.use ReadState
          b.use Call, IsCreated do |env1, b1|   
            if env1[:result] == :created
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result] == :stopped
                  env2[:ui].info(I18n.t("cloudcenter.starting"))
                  b2.use action_prepare_boot
                  b2.use StartInstance 
                else
                  env2[:ui].info(I18n.t("cloudcenter.already_running"))
                end
              end
            else
              env1[:ui].info(I18n.t("cloudcenter.deploying"))
              b1.use action_prepare_boot
              b1.use Deploy
            end
          end

        end
      end
      
      def self.action_sync
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b1|
            if env[:result] != :created
              env[:ui].info(I18n.t("cloudcenter.not_created"))
            else
              b1.use ReadSSHInfo
              b1.use SyncedFolders
            end
            
          end
        end
      end


      # This action is called when `vagrant provision` is called.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if env[:result] != :created
              env[:ui].info(I18n.t("cloudcenter.not_created"))
            else
              b2.use Provision
            end

           
          end
        end
      end

      # The current implementation uses the CloudCenter Jobs API which starts/stops the entire job instead of an individual VM which requires
      # knowledge of the VM ID. There is no reboot/reload option for the jobs API so instead we will stop the job and then start the job 
      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env1, b1|   
            if env1[:result] == :created
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result] == :stopped
                  env2[:ui].info(I18n.t("cloudcenter.already_stopped"))
                  env2[:ui].info(I18n.t("cloudcenter.starting"))
                  b2.use action_prepare_boot
                  b2.use StartInstance 
                else
                  b2.use StopInstance
                  b2.use action_prepare_boot
                  b2.use StartInstance 
                end
              end
            else
              env[:ui].info(I18n.t("cloudcenter.not_created"))
            end
          end

        end
      end

    end
  end
end

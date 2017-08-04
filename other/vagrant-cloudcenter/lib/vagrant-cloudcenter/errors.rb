require "vagrant"

module VagrantPlugins
  module Cloudcenter
    module Errors
      class VagrantCloudcenterError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_cloudcenter.errors")
      end

      class FogError < VagrantAWSError
        error_key(:fog_error)
      end

      class InternalFogError < VagrantAWSError
        error_key(:internal_fog_error)
      end

      class InstanceReadyTimeout < VagrantAWSError
        error_key(:instance_ready_timeout)
      end

      class InstancePackageError < VagrantAWSError
        error_key(:instance_package_error)
      end

      class InstancePackageTimeout < VagrantAWSError
        error_key(:instance_package_timeout)
      end

      class RsyncError < VagrantAWSError
        error_key(:rsync_error)
      end

      class MkdirError < VagrantAWSError
        error_key(:mkdir_error)
      end

    end
  end
end
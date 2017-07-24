require "vagrant"

module VagrantPlugins
  module Cloudcenter
    class Config < Vagrant.plugin("2", :config)
      # The access key ID for accessing Cloudcenter.
      #
      # @return [String]
      attr_accessor :access_key

      # The address of the host
      #
      # @return [String]
      attr_accessor :host

      # Comment to use when provisioning the VM
      #
      # @return [String]
      attr_accessor :username

      # JSON config representing the environment to be deployed
      #
      # @return [String]
      attr_accessor :deployment_config

      # Whether or not to use HTTPS
      #
      # @return [boolean]
      attr_accessor :use_https

      # Path to the SSL CA file
      #
      # @return [String]
      attr_accessor :ssl_ca_file

      def initialize()
        @access_key = UNSET_VALUE
        @host = UNSET_VALUE
        @username = UNSET_VALUE
        @deployment_config = UNSET_VALUE
        @use_https = true
        @ssl_ca_file = ''
	  end
    end
  end
end

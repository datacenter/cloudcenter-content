require "pathname"
require "vagrant/action/builder"


module VagrantPlugins
  module Cloudcenter
    module Command

      include Vagrant::Action::Builtin
      
      class Sync < Vagrant.plugin("2", :command)
     
        def self.synopsis
          "Sync files from host to guest"
        end
        
        def execute

          with_target_vms() do |machine|
            machine.action(:sync)
          end
		       
        end
      end

       
    end
  end
end
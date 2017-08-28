module VagrantPlugins
  module Cloudcenter
    module Command
      class Init < Vagrant.plugin("2", :command)
       def self.synopsis
          "Create inital Vagrant file"
        end
        
       # This will build the Vagrantfile and insert the attributes required
        

       def createInitFile()

			script = File.open("Vagrantfile", "w")
			
			script.puts "# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

	config.vm.box = 'cloudcenter'
 	
 	config.ssh.private_key_path = ['/Users/MYUSERNAME/.ssh/id_rsa','/Users/MYUSERNAME/.vagrant.d/insecure_private_key']
	config.ssh.insert_key = false

	config.vm.provider :cloudcenter do |cloudcenter|
		
		cloudcenter.username = 'my_username'
		cloudcenter.access_key = 'my_access_key'

		cloudcenter.host = 'cloudcenter_host_address'
		cloudcenter.deployment_config = 'sample_deployment_config.json'

		cloudcenter.use_https = true
		cloudcenter.ssl_ca_file = '/path/to/ca_file'

	end
  
  	config.vm.synced_folder '.', '/opt/my_files/', type: 'rsync'

end"
			script.close   

		end
		
		
        
        def execute
          
			createInitFile()
			
        end
      end
    end
  end
end
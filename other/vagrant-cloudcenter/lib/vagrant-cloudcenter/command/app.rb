module VagrantPlugins
  module Cloudcenter
    module Command
      class App < Vagrant.plugin("2", :command)
       def self.synopsis
          "Retrieve application details"
        end
        
        def execute
          
          	RestClient.log = 'stdout'
           	# Get the rest API key for authentication
	        

			host =  ENV['host']
			access_key =  ENV['access_key']
			username =  ENV['username']

			options = {}
			options[:force] = false

			opts = OptionParser.new do |o|
			  o.banner = "Usage: vagrant cloudcenter app [application-id]"
			  o.separator ""

			end

			# Parse the options
			argv = parse_options(opts)

			puts argv[0]

          	begin

	          	if argv[0] && argv[0].match(/\A\d+\z/)

		            encoded = URI.encode("https://#{username}:#{access_key}@#{host}/v1/apps/#{argv[0]}");           
		            
		            catalog = JSON.parse(RestClient::Request.execute(
		   					:method => :get,
		  					:url => encoded,
		                    #:verify_ssl => false,
		                    :content_type => "json",
		                    :accept => "json"
											));
		            puts JSON.pretty_generate(catalog)

				end
          	rescue => e

	            if e.to_s == "SSL_connect returned=1 errno=0 state=error: certificate verify failed"
                  puts "\n ERROR: Failed to verify certificate\n\n"
                  exit
                elsif e.to_s == "401 Unauthorized"
                  puts "\n ERROR: Incorrect credentials\n\n"
                  exit
                elsif e.to_s == "hostname \"#{host}\" does not match the server certificate"
                  puts "\n ERROR: Hostname \"#{host}\" does not match the server certificate\n\n"
                  exit
                elsif e.to_s.include? "No route to host"
                  puts "\n ERROR: No route to host. Check connectivity and try again\n\n"
                  exit
                elsif e.to_s.== "Timed out connecting to server"
                  puts "\n ERROR: Timed out connecting to server. Check connectivity and try again\n\n"
                  exit
                elsif e.to_s.== "getaddrinfo: nodename nor servname provided, or not known"
                  puts "\n ERROR: Unable to connect to \"#{host}\" \n\n"
                  exit
                else
                  error = JSON.parse(e.response) 
                  code = error["errors"][0]["code"] 

                  puts "\n Error code: #{error['errors'][0]['code']}\n"
                  puts "\n #{error['errors'][0]['message']}\n\n"

                  exit
                end
			end	
			
          
         	0
          
		  
				
        end
      end
    end
  end
end
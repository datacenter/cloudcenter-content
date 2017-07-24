module VagrantPlugins
  module Cloudcenter
    module Command
      class Catalog < Vagrant.plugin("2", :command)
       def self.synopsis
          "Retrieve available catalog items"
        end

        def execute
          	
          	access_key = ""
            username = ""
            host = ""

			if File.exists?("VagrantFile")
				File.readlines("VagrantFile").grep(/cloudcenter.access_key/) do |line|
				    unless line.empty?
				      access_key = line.scan(/["']([^"']*)["']/)[0][0]
				    end
				end
				File.readlines("VagrantFile").grep(/cloudcenter.username/) do |line|
				    unless line.empty?
				      username = line.scan(/["']([^"']*)["']/)[0][0]
				      
				    end
				end
				File.readlines("VagrantFile").grep(/cloudcenter.host/) do |line|
				    unless line.empty?
				      host = line.scan(/["']([^"']*)["']/)[0][0]
				      
				    end
				end
			end

			if access_key.empty?
				access_key = ENV["access_key"]
			end
			if username.empty?
				username = ENV["username"]
			end
			if host.empty?
				host = ENV["host"]
			end

			if access_key.nil?
				puts "Access Key missing. Please enter into VagrantFile or environmental variable 'export access_key= '"
			end
			if username.nil?
				puts "Username missing. Please enter into VagrantFile or environmental variable 'export username= '"
			end
			if host.nil?
				puts "Host IP missing. Please enter into VagrantFile or environmental variable 'export host= '"
			end

			if !(access_key.nil? or username.nil? or host.nil?)
          		begin

		            encoded = URI.encode("https://#{username}:#{access_key}@#{host}/v1/apps");           
		            
		            catalog = JSON.parse(RestClient::Request.execute(
		   									:method => :get,
		  									:url => encoded,
		                    #:verify_ssl => false,
		                    :content_type => "json",
		                    :accept => "json"
											));

		            catalogs = catalog["apps"]
				 
				 	
					 # build table with data returned from above function
					
					table = Text::Table.new
					table.head = ["ID", "Name", "Versions", "Category"]
					puts "\n"
				
					#for each item in returned list, display certain attributes in the table
					catalogs.each do |row|
						id = row["serviceTierId"]
						appName = row["name"]
						description = row["description"]
						versions = row["versions"]
						category = row["category"]
								
						table.rows << ["#{id}","#{appName}", "#{versions}", "#{category}"]
					end
				
					puts table
					
					puts"\n"

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
			end
          
         	0
          
		  
				
        end
      end
    end
  end
end
require "log4r"
require "json"

module VagrantPlugins
  module Cloudcenter
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app = app
        end

        def call(env)
              
              if !File.exists?(env[:machine].provider_config.deployment_config)
                puts "Missing deployment_config file"
                exit
              end

          if !env[:machine_public_ip]
            
            begin
              
              if !env[:machine_name]
                deployment_config = JSON.parse(File.read(env[:machine].provider_config.deployment_config))
                env[:machine_name] = deployment_config["name"]
              end

              access_key = env[:machine].provider_config.access_key
              host = env[:machine].provider_config.host
              username = env[:machine].provider_config.username

              use_https = env[:machine].provider_config.use_https
              ssl_ca_file = env[:machine].provider_config.ssl_ca_file

              encoded = URI.encode("https://#{username}:#{access_key}@#{host}/v2/jobs?search=[deploymentEntity.name,fle,#{env[:machine_name]}]");           
            
              if !use_https
                  response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :verify_ssl => false,
                        :accept => "json",
                        :headers => {"Content-Type" => "application/json"}
                      ));
                else
                  if ssl_ca_file.to_s.empty?
                    response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :accept => "json",
                        :headers => {"Content-Type" => "application/json"}
                      ));
                  else
                    response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :ssl_ca_file => ssl_ca_file.to_s,
                        :accept => "json",
                        :headers => {"Content-Type" => "application/json"}
                      ));
                  end
                  
                end
              
              jobID = response["jobs"][0]["id"]

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

              begin
                encoded = URI.encode("https://#{username}:#{access_key}@#{host}/v2/jobs/#{jobID}");           
            
                if !use_https
                    response = JSON.parse(RestClient::Request.execute(
                      :method => :get,
                      :url => encoded,
                      :verify_ssl => false,
                      :accept => "json"
                    ));
                  else
                    if ssl_ca_file.to_s.empty?
                      response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :accept => "json"
                      ));
                    else
                      response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :ssl_ca_file => ssl_ca_file.to_s,
                        :accept => "json"
                      ));
                    end
                  end

              rescue => e
                if e.to_s == "SSL_connect returned=1 errno=0 state=error: certificate verify failed"
                  puts "\n ERROR: Failed to verify certificate\n\n"
                  exit
                elsif e.to_s == "hostname \"#{host}\" does not match the server certificate"
                  puts "\n ERROR: Hostname \"#{host}\" does not match the server certificate\n\n"
                  exit
                elsif e.to_s == "401 Unauthorized"
                  puts "\n ERROR: Incorrect credentials\n\n"
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

              env[:machine_public_ip] = response["accessLink"][7,response.length]

          end 


          env[:machine_ssh_info] = { :host =>  env[:machine_public_ip], :port => 22, :username => "vagrant",:private_key_path => env[:machine].config.ssh.private_key_path}

          env[:ssh_info]  = { :host =>  env[:machine_public_ip], :port => 22, :username => "vagrant",:private_key_path => env[:machine].config.ssh.private_key_path}

          @app.call(env)
        end

      end
    end
  end
end

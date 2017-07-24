require "log4r"
require "json"

require 'vagrant/util/retryable'

require 'vagrant-cloudcenter/util/timer'

module VagrantPlugins
  module Cloudcenter
    module Action
      # This starts a stopped instance.
      class StartInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("cloudcenter::action::start_instance")
        end

        def call(env)
              if !File.exists?(env[:machine].provider_config.deployment_config)
                puts "Missing deployment_config file"
                exit
              end
               
          countdown = 24

          if !env[:machine_name]
                deployment_config = JSON.parse(File.read(env[:machine].provider_config.deployment_config))
                env[:machine_name] = deployment_config["name"]
              end

              access_key = env[:machine].provider_config.access_key
              host = env[:machine].provider_config.host
              username = env[:machine].provider_config.username

              use_https = env[:machine].provider_config.use_https
              ssl_ca_file = env[:machine].provider_config.ssl_ca_file

              begin 
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
                        
              
                if !response["jobs"].empty?
                  jobID = response["jobs"][0]["id"]
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

              if !jobID.nil?
                begin
                  encoded = URI.encode("https://#{username}:#{access_key}@#{host}/v2/jobs/#{jobID}");           
              
                  payload = { "action" => "RESUME" }

                  payload = JSON.generate(payload)


                  if !use_https
                    response = JSON.parse(RestClient::Request.execute(
                          :method => :put,
                          :url => encoded,
                          :verify_ssl => false,
                          :accept => "json",
                          :payload => payload,
                          :headers => {"Content-Type" => "application/json"}
                        ));
                  else
                    if ssl_ca_file.to_s.empty?
                      response = JSON.parse(RestClient::Request.execute(
                          :method => :put,
                          :url => encoded,
                          :accept => "json",
                          :payload => payload,
                          :headers => {"Content-Type" => "application/json"}
                        ));
                    else
                      response = JSON.parse(RestClient::Request.execute(
                          :method => :put,
                          :url => encoded,
                          :accept => "json",
                          :payload => payload,
                          :headers => {"Content-Type" => "application/json"},
                           :ssl_ca_file => ssl_ca_file.to_s
                        ));
                    end
                    
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
                 
                      while (countdown > 0 )
                        
                        countdown -= 1

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

                        if response["deploymentEntity"]["attributes"]["status"] == "Deployed"       
                          env[:state] = :stopped
                          env[:ui].info(I18n.t("cloudcenter.ready"))
                          break
                        else
                          env[:ui].info(I18n.t("cloudcenter.starting"))
                        end
                        
                        sleep 20

                      end 
                  
    
              end
           

          @app.call(env)
        end
      end
    end
  end
end

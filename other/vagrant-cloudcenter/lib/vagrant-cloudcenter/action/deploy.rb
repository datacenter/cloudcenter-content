
require "log4r"
require 'rest-client';
require 'json';
require 'base64'

require 'vagrant/util/retryable'

require 'vagrant-cloudcenter/util/timer'

module VagrantPlugins
  module Cloudcenter
    module Action
     
      class Deploy
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("cloudcenter::action::connect")
        end

        def call(env)
          
          # Get the rest API key for authentication
          access_key = env[:machine].provider_config.access_key
          host = env[:machine].provider_config.host
          username = env[:machine].provider_config.username
  			  use_https = env[:machine].provider_config.use_https
          ssl_ca_file = env[:machine].provider_config.ssl_ca_file

          countdown = 24

          #@logger.info("Deploying VM to Cloudcenter...")

          begin

            if !File.exists?(env[:machine].provider_config.deployment_config)
              puts "\nMissing deployment_config file\n\n"
              exit
            end

            deployment_config = File.read(env[:machine].provider_config.deployment_config)
            tmp = JSON.parse(deployment_config)
            env[:machine_name] = tmp["name"]

            encoded = URI.encode("https://#{username}:#{access_key}@#{host}/v2/jobs");           
            
             if !use_https
                response = JSON.parse(RestClient::Request.execute(
                  :method => :post,
                    :url => encoded,
                    :verify_ssl => false,
                    :accept => "json",
                    :payload => deployment_config,
                    :headers => {"Content-Type" => "application/json"}
                  ));
                else
                  if ssl_ca_file.to_s.empty?
                    response = JSON.parse(RestClient::Request.execute(
                      :method => :post,
                      :url => encoded,
                      :accept => "json",
                      :payload => deployment_config,
                      :headers => {"Content-Type" => "application/json"}
                    ));
                  else
                    response = JSON.parse(RestClient::Request.execute(
                      :method => :post,
                      :url => encoded,
                      :ssl_ca_file => ssl_ca_file.to_s,
                      :accept => "json",
                      :payload => deployment_config,
                      :headers => {"Content-Type" => "application/json"}
                    ));
                    end
                  end
            
            jobID = response["id"]

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
                  :accept => "json",
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

            status = response["status"]

                # Wait for SSH to be ready.
                env[:ui].info(I18n.t("cloudcenter.waiting_for_ready"))
               
                while countdown > 0

                  countdown -= 1
                  
                  # When an  instance comes up, it's networking may not be ready
                  # by the time we connect.
                  begin

                      jobID = response["id"]

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
                              :accept => "json",
                              :ssl_ca_file => ssl_ca_file.to_s
                            ));
                            end
                        end  

                      status = response["status"]
                      
                      
                      if status == "JobRunning" then 
                        env[:machine_state_id]= :created
                        break
                      elsif status == "JobStarting" || status == "JobSubmitted" || status == "JobInProgress" || status == "JobResuming"
                        env[:ui].info(I18n.t("cloudcenter.waiting_for_ssh"))
                      elsif status == "JobError" 
                        puts "\nError deploying VM...\n"
                        puts "\n#{response['jobStatusMessage']}\n\n"
                        exit
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

                  sleep 20
                end
             
            env[:machine_public_ip] = response["accessLink"][7,response.length]
        
            # Ready and booted!
            env[:ui].info(I18n.t("cloudcenter.ready"))
         

          @app.call(env)



        end
      end
    end
  end
end

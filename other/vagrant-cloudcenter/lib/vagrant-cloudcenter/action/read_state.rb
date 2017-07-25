require "log4r"

module VagrantPlugins
  module Cloudcenter
    module Action
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("cloudcenter::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state( env[:machine])

          @app.call(env)
        end

        def read_state(machine)
          return :not_created if machine.id.nil?

          return env[:machine_state_id]
        end
      end
    end
  end
end

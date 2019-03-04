require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action, logger)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      request_log(logger)

      set_default_headers
      send(action)
      write_response

      response_log(logger)
      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

    def request_log(logger)
      logger.info("Request: #{@request.request_method} #{@request.fullpath}")
      logger.info("Handler: #{self.class.name}##{@request.env['simpler.action']}")
      logger.info("Parameters: #{@request.params}")
    end

    def response_log(logger)
      status = @response.status
      logger.info("Response: #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]} [#{@response['Content-Type']}] #{@request.env['simpler.template_path']}")
    end

  end
end

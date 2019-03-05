require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      merge_params
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

    def merge_params
      @request.params.merge!(@request.env['simpler.route_params'])
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      plain = @request.env['simpler.plain']
      body = plain ? plain : render_body
      @response.write(body)

      status = @request.env['simpler.status']
      @response.status = status if status

      headers.each { |name, value| @response.set_header(name, value) }
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def render(template = nil, plain: nil)
      @request.env['simpler.template'] = template and return if template
      @request.env['simpler.plain'] = plain if plain
    end

    def status(code)
      @request.env['simpler.status'] = code
    end

    def headers
      @request.env['simpler.headers'] ||= {}
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

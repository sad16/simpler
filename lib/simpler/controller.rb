require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response

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

  end
end

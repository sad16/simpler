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

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response

      @response.finish
    end

    def params
      @request.env['simpler.all_params']
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def merge_params
      @request.env['simpler.all_params'] = @request.params.merge(@request.env['simpler.route_params'])
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      @response.write(render_body)
    end

    def render_body
      set_content_type_header if @request.env['simpler.template'].is_a?(Hash)

      View.new(@request.env).render(binding)
    end

    def set_content_type_header
      case @request.env['simpler.template'].keys.first
      when :plain
        @response['Content-Type'] = 'text/plain'
      end
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

    def status(code)
      @response.status = code
    end

    def headers
      @response.headers
    end

  end
end

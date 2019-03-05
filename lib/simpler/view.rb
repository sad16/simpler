require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      return format_render if template.is_a?(Hash)

      template = File.read(template_path)

      ERB.new(template).result(binding)
    end

    private

    def format_render
      case template.keys.first
      when :plain
        template[:plain]
      else
        raise 'Error render format'
      end
    end

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def template_path
      path = template || [controller.name, action].join('/')
      @env['simpler.template_path'] = "#{path}.html.erb"

      Simpler.root.join(VIEW_BASE_PATH, @env['simpler.template_path'])
    end

  end
end

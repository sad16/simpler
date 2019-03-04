require 'logger'

class AppLogger
  def initialize(app, **options)
    @logger = Logger.new(options[:logdev] || STDOUT)
    @app = app
  end

  def call(env)
    @app.call(env, @logger)
  end
end

# Request: GET /tests?category=Backend
# Handler: TestsController#index
# Parameters: {'category' => 'Backend'}
# Response: 200 OK [text/html] tests/index.html.erb

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
# require 'action_mailer/railtie'
# require 'action_mailbox/engine'
# require 'action_text/engine'
require 'action_view/railtie'
# require 'action_cable/engine'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Library
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    config.i18n.available_locales = %i[en ru]
    config.i18n.default_locale = :ru
    config.time_zone = 'Moscow'

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    # config.eager_load_paths << Rails.root.join('extras')
    config.cache_store = :redis_cache_store, { url: ENV['REDIS_CACHE_URL'] }
    config.session_store :redis_store,
      servers: [ENV['REDIS_SESSION_URL']],
      expire_after: 90.minutes,
      key: '_library_session',
      threadsafe: false

    config.generators do |g|
      g.org             :active_record
      g.template_engine :slim
      g.system_tests    nil
      g.test_framework  :rspec, controller_specs: false
      g.helper          false
      g.stylesheets     false
      g.javascript      false
      g.factory_bot     dir: 'spec/factories'
    end

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end

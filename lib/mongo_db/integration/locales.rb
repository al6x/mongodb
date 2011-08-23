require 'i18n'

dir = File.dirname __FILE__
I18n.load_path += Dir["#{dir}/locales/**/*.{rb,yml}"]
gem 'mongo',    '~> 1.3'
gem 'i18n',     '>= 0.5'

if respond_to? :fake_gem
  fake_gem 'ruby_ext'
end
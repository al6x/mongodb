require 'rake_ext'

project(
  name: "mongodb",
  # version: '0.1.0',
  gem: true,
  summary: "Persistence for any Ruby Object & Driver enhancements for MongoDB.",

  author: "Alexey Petrushin",
  homepage: "http://github.com/alexeypetrushin/mongodb"
)

desc "Generate documentation"
task :docs do
  %x(cd docs && rocco -o site *.rb)
end
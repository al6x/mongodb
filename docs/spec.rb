require 'open3'

dir = File.expand_path "#{__FILE__}/../.."

describe "Documentation" do
  %w(
    driver
    migration
    persistence
  ).each do |name|
    it "should execute '#{name}.rb' without errors" do
      stdin, stdout, stderr = Open3.popen3 "ruby #{dir}/docs/#{name}.rb"
      stderr.read.should be_empty
    end
  end
end
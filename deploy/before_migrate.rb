require 'net/http'
require 'uri'
require 'json'

Chef::Log.logger.info "app:deploy/before_migrate.rb"

begin
  slack_hook_url = node[:deploy][:rails_opsworks][:environment_variables][:app_slack_hook_url]
  Chef::Log.logger.info "post to #{slack_hook_url}"

  uri  = URI.parse(slack_hook_url)
  text = <<-EOL
  Start deployment by #{node[:deploy][:rails_opsworks][:deploying_user]}
  env: #{node[:deploy][:rails_opsworks][:rails_env]}
  repo: #{node[:deploy][:rails_opsworks][:scm][:repository]}
  revision: #{node[:deploy][:rails_opsworks][:scm][:revision]}
  EOL
  params = { text: text }
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.start do
    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(payload: params.to_json)
    http.request(request)
  end
rescue => e
  Chef::Log.logger.error e.message
  Chef::Log.logger.error e.backtrace.join("\n")
end

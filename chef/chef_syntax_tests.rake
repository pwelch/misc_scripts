# Testing tasks
namespace :test do
  desc 'Runs ruby or jq syntax check on roles'
  task :roles do
    puts '===== Running ruby syntax check on roles'

    Dir.foreach('roles/') do |file|
      if file =~ /.rb$/
        sh "ruby -c roles/#{file}"
      elsif file =~ /.json$/
        sh "cat roles/#{file} | jq . > /dev/null"
      end
    end
  end

  desc 'Runs ruby or jq syntax check on environments'
  task :environments do
    puts '===== Running ruby syntax check on environments'

    Dir.foreach('environments/') do |file|
      if file =~ /.rb$/
        sh "ruby -c environments/#{file}"
      elsif file =~ /.json$/
        sh "cat environments/#{file} | jq . > /dev/null"
      end
    end
  end
end
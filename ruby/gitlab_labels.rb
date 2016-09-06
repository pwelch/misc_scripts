require 'gitlab'

# Copies Gitlab project labels from an existing project to a new one

class Project
  attr_accessor :group, :project, :name
  def initialize(proj)
    p = proj.split('/')
    @group    = p[0]
    @project  = p[1]
    @name     = proj
  end

  def project_id
    return "#{group}%2F#{project}"
  end
end


def run(old, new)
  from = Project.new(old)
  to   = Project.new(new)

  begin
    labels_to_copy = Gitlab.labels(from.project_id)
  rescue Gitlab::Error::Error => error
    puts error; exit 1
  end

  labels_to_copy.each do |l|
    label = l.to_hash
    puts "Creating #{label["name"]} in #{to.name}"
    begin
      Gitlab.create_label(to.project_id, label["name"], label["color"])
    rescue Gitlab::Error::Error => error
      if error.class == Gitlab::Error::Conflict
        puts "  label already exists, moving on..."
        next
      end
      puts error; exit 1
    end
  end
end

Gitlab.configure do |config|
  config.endpoint       = '' # Gitlab server ('https://gitlab.com/api/v3')
  config.private_token  = '' # https://gitlab.com/profile/account
end

run('group_name/project_name', 'group_name/project_name')


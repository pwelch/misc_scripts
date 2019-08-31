# Print out Chef node info to markdown table using knife exec script 
#
# https://docs.chef.io/knife_exec.html
# chef exec knife exec info.rb > output.md

# Collect all of the nodes from the Chef Server
@chef_nodes = nodes.list.take(5) # limit 5 for testing

# Create a Markdown table template
require 'erb'
output_template = <<-DOC
| Name | Chef_Environment | Run_List | Tags |
| ---- | ---------------- | -------- | ---- |
|      |                  |          |      |
<% @chef_nodes.each do |node| -%>
| <%= node.name %> | <%= node.chef_environment %> | <%= node.run_list %> | <%= node.tags %> |
<% end -%>
DOC

# Render template with content
renderer = ERB.new(output_template, 1, "-")
output = renderer.result(binding)

# Output results
puts output

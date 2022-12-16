require 'aws-record'
<% if has_validations? -%>
require 'active_model'
<% end -%>

<% module_namespacing do -%>
class <%= class_name %>
  include Aws::Record
<% if options.key? :scaffold -%>
  extend ActiveModel::Naming
<% end -%>
<% if has_validations? -%>
  include ActiveModel::Validations
<% end -%>
<% if options.key? :password_digest -%>
  include ActiveModel::SecurePassword
<% end -%>
<% if mutation_tracking_disabled? -%>
  disable_mutation_tracking
<% end -%>

<% attributes.each do |attribute| -%>
  <%= attribute.type %> :<%= attribute.name %><% *opts, last_opt = attribute.options.to_a %><%= ', ' if last_opt %><% opts.each do |opt| %><%= opt[0] %>: <%= opt[1] %>, <% end %><% if last_opt %><%= last_opt[0] %>: <%= last_opt[1] %><% end %>
<% end -%>
<% gsis.each do |index| %>
  global_secondary_index(
    :<%= index.name %>,
    hash_key: :<%= index.hash_key -%>,<%- if index.range_key %>
    range_key: :<%= index.range_key -%>,<%- end %>
    projection: {
      projection_type: <%= index.projection_type %>
    }
  )
<% end -%>
<% if !required_attrs.empty? -%>
  validates_presence_of <% *req, last_req = required_attrs -%><% req.each do |required_validation|-%>:<%= required_validation %>, <% end -%>:<%= last_req %>
<% end -%>
<% length_validations.each do |attribute, validation| -%>
  validates_length_of :<%= attribute %>, within: <%= validation %>
<% end -%>
<% if options['table_name'] -%>
  set_table_name "<%= options['table_name'] %>"
<% end -%>
<% if options.key? :password_digest -%>
  has_secure_password
<% end -%>
end
<% end -%>

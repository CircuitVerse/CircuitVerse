require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class <%= class_name %>

      t.read_capacity_units <%= primary_read_units %>
      t.write_capacity_units <%= primary_write_units %>
      <%- gsis.each do |index| %>
      t.global_secondary_index(:<%= index.name %>) do |i|
        i.read_capacity_units <%= gsi_rw_units[index.name][0] %>
        i.write_capacity_units <%= gsi_rw_units[index.name][1] %>
      end
      <%- end -%>
    end
  end
end

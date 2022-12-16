module ModelReconstruction
  def reset_class(class_name)
    ActiveRecord::Base.include Paperclip::Glue
    begin
      Object.send(:remove_const, class_name)
    rescue StandardError
      nil
    end
    klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))

    klass.class_eval do
      include Paperclip::Glue
    end

    klass.reset_column_information
    klass.connection_pool.clear_table_cache!(klass.table_name) if klass.connection_pool.respond_to?(:clear_table_cache!)

    if klass.connection.respond_to?(:schema_cache)
      if ActiveRecord::VERSION::STRING >= "5.0"
        klass.connection.schema_cache.clear_data_source_cache!(klass.table_name)
      else
        klass.connection.schema_cache.clear_table_cache!(klass.table_name)
      end
    end

    klass
  end

  def reset_table(_table_name, &block)
    block ||= lambda { |_table| true }
    ActiveRecord::Base.connection.create_table :dummies, **{ force: true }, &block
  end

  def modify_table(&block)
    ActiveRecord::Base.connection.change_table :dummies, &block
  end

  def rebuild_model(options = {})
    ActiveRecord::Base.connection.create_table :dummies, force: true do |table|
      table.column :title, :string
      table.column :other, :string
      table.column :avatar_file_name, :string
      table.column :avatar_content_type, :string
      table.column :avatar_file_size, :bigint
      table.column :avatar_updated_at, :datetime
      table.column :avatar_fingerprint, :string
    end
    rebuild_class options
  end

  def rebuild_class(options = {})
    reset_class("Dummy").tap do |klass|
      klass.has_attached_file :avatar, options
      klass.do_not_validate_attachment_file_type :avatar
      Paperclip.reset_duplicate_clash_check!
    end
  end

  def rebuild_meta_class_of(obj, options = {})
    meta_class_of(obj).tap do |metaklass|
      metaklass.has_attached_file :avatar, options
      metaklass.do_not_validate_attachment_file_type :avatar
      Paperclip.reset_duplicate_clash_check!
    end
  end

  def meta_class_of(obj)
    class << obj
      self
    end
  end
end

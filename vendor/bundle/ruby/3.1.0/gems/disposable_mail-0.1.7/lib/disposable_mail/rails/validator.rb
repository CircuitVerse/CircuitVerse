class UndisposableValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if DisposableMail.include?(value)
      record.errors.add(attribute, :undisposable, options)
    end
  end
end

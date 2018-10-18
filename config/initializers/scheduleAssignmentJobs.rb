if Assignment.table_exists?
  Assignment.all.each do |ass|
    if ass.status == 'open' and ass.deadline < Time.now
      ass.set_deadline_job
    end
  end
end

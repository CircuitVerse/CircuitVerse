class Project < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_many :forks , class_name: 'Project', foreign_key: 'forked_project_id', dependent: :nullify
  belongs_to :forked_project , class_name: 'Project' , optional: true
  has_many :stars , dependent: :destroy
  has_many :user_ratings, through: :stars , dependent: :destroy ,source: 'user'
  belongs_to :assignment , optional: true

  has_many :collaborations, dependent: :destroy
  has_many :collaborators, source: 'user' , through: :collaborations
  has_many :taggings
  has_many :tags, through: :taggings
  mount_uploader :image_preview, ImagePreviewUploader

  self.per_page = 8

  acts_as_commontable
  # after_commit :send_mail, on: :create

  def check_edit_access(user)
    @user_access =
        ((!user.nil? and self.author_id == user.id and self.project_submission != true) \
        or (!user.nil? and Collaboration.find_by(project_id:self.id,user_id:user.id)))

  end

  def check_view_access(user)
    @user_access =
        (self.project_access_type != "Private" \
        or (!user.nil? and self.author_id==user.id) \
        or (!user.nil? and !self.assignment_id.nil? and self.assignment.group.mentor_id==user.id) \
        or (!user.nil? and Collaboration.find_by(project_id:self.id,user_id:user.id)) \
        or (!user.nil? and user.admin))
  end


  def check_direct_view_access(user)
    @user_access =
        (self.project_access_type == "Public" or \
        (self.project_submission == false and  !user.nil? and self.author_id==user.id) or \
        (!user.nil? and Collaboration.find_by(project_id:self.id,user_id:user.id)) or \
        (!user.nil? and user.admin))
  end

  def increase_views(user)

    if user.nil? or user.id != self.author_id
      self.view ||=0
      self.view += 1
      self.save
    end
  end


  def send_mail
    if(self.forked_project_id.nil?)
      if(self.project_submission == false)
        UserMailer.new_project_email(self.author,self).deliver_later
      end
    else
      if(self.project_submission == false)
        UserMailer.forked_project_email(self.author,self.forked_project,self).deliver_later
      end
    end
  end

  def self.tagged_with(name)
    Tag.find_by!(name: name).projects
  end

  def tag_list
    tags.map(&:name).join(', ')
  end

  def tag_list=(names)
    self.tags = names.split(',').map do |n|
      Tag.where(name: n.strip).first_or_create!
    end
  end
  
  private
  def check_validity
    if project_access_type != "Private" and !assignment_id.nil?
      errors.add(:project_access_type, "Assignment has to be private")
    end
  end


end

class UserSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :email, :name, :admin,
             :country, :educational_institute,
             :subscribed, :created_at, :updated_at

end

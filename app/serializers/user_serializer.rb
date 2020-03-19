class UserSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :email, :name, :admin,
             :country, :educational_institute,
             :subscribed

end

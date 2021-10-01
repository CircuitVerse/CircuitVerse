module ActivityNotification
  module Swagger::NotificationSchema #:nodoc:
    extend ActiveSupport::Concern
    include ::Swagger::Blocks
  
    included do
      swagger_component do
        schema :NotificationAttributes do
          key :type, :object
          property :id do
            key :oneOf, [
              { type: :integer },
              { type: :string }
            ]
            key :description, "This parameter type is integer with ActiveRecord, but will be string with Mongoid or Dynamoid ORMs."
            key :example, 123
          end
          property :target_type do
            key :type, :string
            key :example, "User"
          end
          property :target_id do
            key :oneOf, [
              { type: :integer },
              { type: :string }
            ]
            key :description, "This parameter type is integer with ActiveRecord, but will be string with Mongoid or Dynamoid ORMs."
            key :example, 1
          end
          property :notifiable_type do
            key :type, :string
            key :example, "Comment"
          end
          property :notifiable_id do
            key :oneOf, [
              { type: :integer },
              { type: :string }
            ]
            key :description, "This parameter type is integer with ActiveRecord, but will be string with Mongoid or Dynamoid ORMs."
            key :example, 22
          end
          property :key do
            key :type, :string
            key :example, "comment.default"
          end
          property :group_type do
            key :type, :string
            key :nullable, true
            key :example, "Article"
          end
          property :group_id do
            key :oneOf, [
              { type: :integer },
              { type: :string },
              { nullable: true }
            ]
            key :description, "This parameter type is integer with ActiveRecord, but will be string with Mongoid or Dynamoid ORMs."
            key :nullable, true
            key :example, 11
          end
          property :group_owner_id do
            key :oneOf, [
              { type: :integer },
              { type: :string },
              { type: :object },
              { nullable: true }
            ]
            key :description, "This parameter type is integer with ActiveRecord, but will be string or object including $oid with Mongoid or Dynamoid ORMs."
            key :nullable, true
            key :example, 123
          end
          property :notifier_type do
            key :type, :string
            key :nullable, true
            key :example, "User"
          end
          property :notifier_id do
            key :oneOf, [
              { type: :integer },
              { type: :string },
              { nullable: true }
            ]
            key :description, "This parameter type is integer with ActiveRecord, but will be string with Mongoid or Dynamoid ORMs."
            key :nullable, true
            key :example, 2
          end
          property :parameters do
            key :type, :object
            key :additionalProperties, {
              type: :string
            }
            key :example, {
              test_default_param: "1"
            }
          end
          property :opened_at do
            key :type, :string
            key :format, :'date-time'
            key :nullable, true
          end
          property :created_at do
            key :type, :string
            key :format, :'date-time'
          end
          property :updated_at do
            key :type, :string
            key :format, :'date-time'
          end
        end

        schema :Notification do
          key :type, :object
          key :required, [ :id, :target_type, :target_id, :notifiable_type, :notifiable_id, :key, :created_at, :updated_at, :target, :notifiable ]
          allOf do
            schema do
              key :'$ref', :NotificationAttributes
            end
            schema do
              key :type, :object
              property :notifiable_path do
                key :type, :string
                key :format, :uri
                key :example, "/articles/11"
              end
              property :printable_notifiable_name do
                key :type, :string
                key :format, :uri
                key :example, "comment \"This is the first Stephen's comment to Ichiro's article.\""
              end
              property :group_member_notifier_count do
                key :type, :integer
                key :example, 1
              end
              property :group_notification_count do
                key :type, :integer
                key :example, 2
              end
              property :target do
                key :type, :object
                key :description, "Associated target model in your application"
                key :example, {
                  id: 1,
                  email: "ichiro@example.com",
                  name: "Ichiro",
                  created_at: Time.current,
                  updated_at: Time.current,
                  provider: "email",
                  uid: "",
                  printable_type: "User",
                  printable_target_name: "Ichiro"
                }
              end
              property :notifiable do
                key :type, :object
                key :description, "Associated notifiable model in your application"
                key :example, {
                  id: 22,
                  user_id: 2,
                  article_id: 11,
                  body: "This is the first Stephen's comment to Ichiro's article.",
                  created_at: Time.current,
                  updated_at: Time.current,
                  printable_type: "Comment"
              }
              end
              property :group do
                key :type, :object
                key :description, "Associated group model in your application"
                key :nullable, true
                key :example, {
                  id: 11,
                  user_id: 4,
                  title: "Ichiro's great article",
                  body: "This is Ichiro's great article. Please read it!",
                  created_at: Time.current,
                  updated_at: Time.current,
                  printable_type: "Article",
                  printable_group_name: "article \"Ichiro's great article\""
                }
              end
              property :notifier do
                key :type, :object
                key :description, "Associated notifier model in your application"
                key :nullable, true
                key :example, {
                  id: 2,
                  email: "stephen@example.com",
                  name: "Stephen",
                  created_at: Time.current,
                  updated_at: Time.current,
                  provider: "email",
                  uid: "",
                  printable_type: "User",
                  printable_notifier_name: "Stephen"
                }
              end
              property :group_members do
                key :type, :array
                items do
                  key :'$ref', :NotificationAttributes
                end
              end
            end
          end
        end
      end
    end
  end
end

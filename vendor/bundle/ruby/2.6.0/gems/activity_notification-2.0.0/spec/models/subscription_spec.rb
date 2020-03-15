# To run as single test for debugging
# require Rails.root.join('../../spec/concerns/apis/subscription_api_spec.rb').to_s

describe ActivityNotification::Subscription, type: :model do

  it_behaves_like :subscription_api

  describe "with association" do
    it "belongs to target" do
      target = create(:confirmed_user)
      subscription = create(:subscription, target: target)
      expect(subscription.reload.target).to eq(target)
    end
  end

  describe "with validation" do
    before { @subscription = build(:subscription) }

    it "is valid with target and key" do
      expect(@subscription).to be_valid
    end

    it "is invalid with blank target" do
      @subscription.target = nil
      expect(@subscription).to be_invalid
      expect(@subscription.errors[:target].size).to eq(1)
    end

    it "is invalid with blank key" do
      @subscription.key = nil
      expect(@subscription).to be_invalid
      expect(@subscription.errors[:key].size).to eq(1)
    end

    #TODO
    # it "is invalid with non boolean value of subscribing" do
      # @subscription.subscribing = 'hoge'
      # expect(@subscription).to be_invalid
      # expect(@subscription.errors[:subscribing].size).to eq(1)
    # end
# 
    # it "is invalid with non boolean value of subscribing_to_email" do
      # @subscription.subscribing_to_email = 'hoge'
      # expect(@subscription).to be_invalid
      # expect(@subscription.errors[:subscribing_to_email].size).to eq(1)
    # end

    it "is invalid with true as subscribing_to_email and false as subscribing" do
      @subscription.subscribing = false
      @subscription.subscribing_to_email = true
      expect(@subscription).to be_invalid
      expect(@subscription.errors[:subscribing_to_email].size).to eq(1)
    end
  end

  describe "with scope" do
    context "to filter by association" do
      before do
        ActivityNotification::Subscription.delete_all
        @target_1, @key_1 = create(:confirmed_user), "key.1"
        @target_2, @key_2 = create(:confirmed_user), "key.2"
        @subscription_1 = create(:subscription, target: @target_1, key: @key_1)
        @subscription_2 = create(:subscription, target: @target_2, key: @key_2)
      end

      it "works with filtered_by_target scope" do
        subscriptions = ActivityNotification::Subscription.filtered_by_target(@target_1)
        expect(subscriptions.size).to eq(1)
        expect(subscriptions.first).to eq(@subscription_1)
        subscriptions = ActivityNotification::Subscription.filtered_by_target(@target_2)
        expect(subscriptions.size).to eq(1)
        expect(subscriptions.first).to eq(@subscription_2)
      end

      it "works with filtered_by_key scope" do
        subscriptions = ActivityNotification::Subscription.filtered_by_key(@key_1)
        expect(subscriptions.size).to eq(1)
        expect(subscriptions.first).to eq(@subscription_1)
        subscriptions = ActivityNotification::Subscription.filtered_by_key(@key_2)
        expect(subscriptions.size).to eq(1)
        expect(subscriptions.first).to eq(@subscription_2)
      end

      describe 'filtered_by_options scope' do
        context 'with filtered_by_key options' do
          it "works with filtered_by_options scope" do
            subscriptions = ActivityNotification::Subscription.filtered_by_options({ filtered_by_key: @key_1 })
            expect(subscriptions.size).to eq(1)
            expect(subscriptions.first).to eq(@subscription_1)
            subscriptions = ActivityNotification::Subscription.filtered_by_options({ filtered_by_key: @key_2 })
            expect(subscriptions.size).to eq(1)
            expect(subscriptions.first).to eq(@subscription_2)
          end
        end

        context 'with custom_filter options' do
          it "works with filtered_by_options scope" do
            subscriptions = ActivityNotification::Subscription.filtered_by_options({ custom_filter: { key: @key_2 } })
            expect(subscriptions.size).to eq(1)
            expect(subscriptions.first).to eq(@subscription_2)
          end

          it "works with filtered_by_options scope with filter depending on ORM" do
            options =
              case ActivityNotification.config.orm
              when :active_record then { custom_filter: ["subscriptions.key = ?", @key_1] }
              when :mongoid       then { custom_filter: { key: {'$eq': @key_1} } }
              when :dynamoid      then { custom_filter: {'key.begins_with': @key_1} }
              end
            subscriptions = ActivityNotification::Subscription.filtered_by_options(options)
            expect(subscriptions.size).to eq(1)
            expect(subscriptions.first).to eq(@subscription_1)
          end
        end
  
        context 'with no options' do
          it "works with filtered_by_options scope" do
            subscriptions = ActivityNotification::Subscription.filtered_by_options
            expect(subscriptions.size).to eq(2)
          end
        end
      end
    end

    context "to make order by created_at" do
      before do
        ActivityNotification::Subscription.delete_all
        @target = create(:confirmed_user)
        @subscription_1 = create(:subscription, target: @target, key: 'key.1')
        @subscription_2 = create(:subscription, target: @target, key: 'key.2', created_at: @subscription_1.created_at + 10.second)
        @subscription_3 = create(:subscription, target: @target, key: 'key.3', created_at: @subscription_1.created_at + 20.second)
        @subscription_4 = create(:subscription, target: @target, key: 'key.4', created_at: @subscription_1.created_at + 30.second)
      end

      unless ActivityNotification.config.orm == :dynamoid
        context "using ORM other than dynamoid, you can directly call latest/earliest order method from class objects" do

          it "works with latest_order scope" do
            subscriptions = ActivityNotification::Subscription.latest_order
            expect(subscriptions.size).to eq(4)
            expect(subscriptions.first).to eq(@subscription_4)
            expect(subscriptions.last).to eq(@subscription_1)
          end

          it "works with earliest_order scope" do
            subscriptions = ActivityNotification::Subscription.earliest_order
            expect(subscriptions.size).to eq(4)
            expect(subscriptions.first).to eq(@subscription_1)
            expect(subscriptions.last).to eq(@subscription_4)
          end

        end
      else
        context "using dynamoid, you can call latest/earliest order method only with query using partition key of Global Secondary Index" do

          it "works with latest_order scope" do
            subscriptions = ActivityNotification::Subscription.filtered_by_target(@target).latest_order
            expect(subscriptions.size).to eq(4)
            expect(subscriptions.first).to eq(@subscription_4)
            expect(subscriptions.last).to eq(@subscription_1)
          end

          it "works with earliest_order scope" do
            subscriptions = ActivityNotification::Subscription.filtered_by_target(@target).earliest_order
            expect(subscriptions.size).to eq(4)
            expect(subscriptions.first).to eq(@subscription_1)
            expect(subscriptions.last).to eq(@subscription_4)
          end

        end
      end

      it "works with latest_order! scope" do
        subscriptions = ActivityNotification::Subscription.latest_order!
        expect(subscriptions.size).to eq(4)
        expect(subscriptions.first).to eq(@subscription_4)
        expect(subscriptions.last).to eq(@subscription_1)
      end

      it "works with latest_order!(reverse=true) scope" do
        subscriptions = ActivityNotification::Subscription.latest_order!(true)
        expect(subscriptions.size).to eq(4)
        expect(subscriptions.first).to eq(@subscription_1)
        expect(subscriptions.last).to eq(@subscription_4)
      end

      it "works with earliest_order! scope" do
        subscriptions = ActivityNotification::Subscription.earliest_order!
        expect(subscriptions.size).to eq(4)
        expect(subscriptions.first).to eq(@subscription_1)
        expect(subscriptions.last).to eq(@subscription_4)
      end

      it "works with latest_subscribed_order scope" do
        Timecop.travel(1.minute.from_now) do
          @subscription_2.subscribe
          subscriptions = ActivityNotification::Subscription.latest_subscribed_order
          expect(subscriptions.size).to eq(4)
          expect(subscriptions.first).to eq(@subscription_2)
        end
      end

      it "works with earliest_subscribed_order scope" do
        Timecop.travel(1.minute.from_now) do
          @subscription_3.subscribe
          subscriptions = ActivityNotification::Subscription.earliest_subscribed_order
          expect(subscriptions.size).to eq(4)
          expect(subscriptions.last).to eq(@subscription_3)
        end
      end

      it "works with key_order scope" do
        subscriptions = ActivityNotification::Subscription.key_order
        expect(subscriptions.size).to eq(4)
        expect(subscriptions.first).to eq(@subscription_1)
        expect(subscriptions.last).to eq(@subscription_4)
      end
    end
  end
end

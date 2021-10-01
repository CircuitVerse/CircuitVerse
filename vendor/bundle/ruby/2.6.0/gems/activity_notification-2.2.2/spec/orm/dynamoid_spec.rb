if ActivityNotification.config.orm == :dynamoid
  describe Dynamoid::Criteria::None do
    let(:none) { ActivityNotification::Notification.none }

    it "is a Dynamoid::Criteria::None" do
      expect(none).to be_a(Dynamoid::Criteria::None)
    end

    context "== operator" do
      it "returns true against other None object" do
        expect(none).to eq(ActivityNotification::Notification.none)
      end

      it "returns false against other objects" do
        expect(none).not_to eq(1)
      end
    end

    context "records" do
      it "returns empty array" do
        expect(none.records).to eq([])
      end
    end

    context "all" do
      it "returns empty array" do
        expect(none.all).to eq([])
      end
    end

    context "count" do
      it "returns 0" do
        expect(none.count).to eq(0)
      end
    end

    context "delete_all" do
      it "does nothing" do
        expect(none.delete_all).to be_nil
      end
    end

    context "empty?" do
      it "returns true" do
        expect(none.empty?).to be_truthy
      end
    end
  end

  describe Dynamoid::Criteria::Chain do
    let(:chain) { ActivityNotification::Notification.scan_index_forward(true) }

    before do
      ActivityNotification::Notification.delete_all
    end

    it "is a Dynamoid::Criteria::None" do
      expect(chain).to be_a(Dynamoid::Criteria::Chain)
    end

    context "none" do
      it "returns Dynamoid::Criteria::None" do
        expect(chain.none).to be_a(Dynamoid::Criteria::None)
      end
    end

    context "limit" do
      before do
        create(:notification)
        create(:notification)
      end

      it "returns limited records by record_limit" do
        expect(chain.count).to eq(2)
        expect(chain.limit(1).count).to eq(1)
      end
    end

    context "exists?" do
      it "returns false when the record does not exist" do
        expect(chain.exists?).to be_falsy
      end

      it "returns true when the record exists" do
        create(:notification)
        expect(chain.exists?).to be_truthy
      end
    end

    context "size" do
      it "returns same value as count" do
        expect(chain.count).to eq(0)
        expect(chain.size).to  eq(0)
        create(:notification)
        expect(chain.count).to eq(1)
        expect(chain.size).to  eq(1)
      end
    end

    context "update_all" do
      before do
        create(:notification)
        create(:notification)
      end

      it "updates all records" do
        expect(ActivityNotification::Notification.where(key: "default.default").count).to eq(2)
        expect(ActivityNotification::Notification.where(key: "updated.all").count).to     eq(0)
        chain.update_all(key: "updated.all")
        expect(ActivityNotification::Notification.where(key: "default.default").count).to eq(0)
        expect(ActivityNotification::Notification.where(key: "updated.all").count).to     eq(2)
      end
    end
  end
end
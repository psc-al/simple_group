RSpec.describe Tag, type: :model do
  it { should have_many(:submission_tags) }
  it { should have_many(:submissions).through(:submission_tags) }

  describe ".for_user" do
    let!(:topic_tag) { create(:topic_tag) }
    let!(:media_tag) { create(:media_tag) }
    let!(:source_tag) { create(:source_tag) }
    let!(:meta_tag) { create(:meta_tag) }
    let(:mod_tag) { create(:mod_tag) }

    context "when the user is an admin" do
      it "returns all the tags" do
        user = create(:user, :admin)

        expect(Tag.for_user(user)).to eq([topic_tag, media_tag, source_tag, meta_tag, mod_tag])
      end
    end

    context "when the user is a moderator" do
      it "returns all the tags" do
        user = create(:user, :moderator)

        expect(Tag.for_user(user)).to eq([topic_tag, media_tag, source_tag, meta_tag, mod_tag])
      end
    end

    context "when the user is a member" do
      it "returns all the tags except mod tags" do
        user = create(:user)

        expect(Tag.for_user(user)).to eq([topic_tag, media_tag, source_tag, meta_tag])
      end
    end
  end
end

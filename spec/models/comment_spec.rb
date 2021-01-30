RSpec.describe Comment, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:submission) }
  it { should belong_to(:parent).optional.class_name("Comment") }
  it { should have_many(:votes) }

  describe ".short_id_prefix" do
    it "is :c_" do
      expect(Comment.short_id_prefix).to eq(:c_)
    end
  end

  describe "#before_create" do
    it "sets its short id to a random 8-character base-36 string prefixed with c_" do
      comment = build(:comment)

      expect(comment.short_id).to be_nil

      comment.save!

      expect(comment.short_id).not_to be_nil
      expect(comment.short_id).to start_with("c_")
      expect(comment.short_id[2..].length).to eq(8)
    end
  end

  describe "#ancestry_path" do
    it "is a `.` connected path containing each ancestral short id in order" do
      comment = create(:comment)
      child = create(:comment, parent: comment)
      grand_child = create(:comment, parent: child)
      great_grand_child = create(:comment, parent: grand_child)

      expect(comment.ancestry_path).to be_nil
      expect(child.ancestry_path).to eq(comment.short_id)
      expect(grand_child.ancestry_path).
        to eq("#{comment.short_id}.#{child.short_id}")
      expect(great_grand_child.ancestry_path).
        to eq("#{comment.short_id}.#{child.short_id}.#{grand_child.short_id}")
    end
  end

  describe "#root_node?" do
    it "is true if the comment has no parent" do
      comment = build(:comment, parent: nil)

      expect(comment).to be_root_node
    end

    it "is false if the comment has a parent" do
      comment = build(:comment, parent: create(:comment))

      expect(comment).not_to be_root_node
    end
  end

  describe "#children" do
    it "returns a list of all the comment's direct children" do
      comment = create(:comment)
      direct_children = create_list(:comment, 3, parent: comment)
      # these shouldn't get returned since they're not direct children
      direct_children.each { |c| create(:comment, parent: c) }

      expect(comment.children).to match_array(direct_children)
    end

    it "is empty if there are no direct children for the comment" do
      comment = create(:comment)

      expect(comment.children).to be_empty
    end
  end

  describe "#childless?" do
    it "is true if the comment has no children" do
      comment = create(:comment)

      expect(comment).to be_childless
    end

    it "is false if the comment has children" do
      comment = create(:comment)
      create_list(:comment, 3, parent: comment)

      expect(comment).not_to be_childless
    end
  end

  describe "#descendants" do
    it "returns a list of all the comments descendants (i.e. all children and their children, etc.)" do
      comment = create(:comment)
      children = create_list(:comment, 3, parent: comment)
      grand_children = children.map { |c| create(:comment, parent: c) }
      great_grand_children = grand_children.map { |c| create(:comment, parent: c) }

      expect(comment.descendants).to match_array(children + grand_children + great_grand_children)
    end

    it "is empty if there are no descendants for the comment" do
      comment = create(:comment)

      expect(comment.descendants).to be_empty
    end
  end

  describe "#siblings" do
    it "returns a list of all the comments siblings (i.e. they share a direct parent)" do
      parent = create(:comment, parent: create(:comment))
      child1, child2, child3 = create_list(:comment, 3, parent: parent)

      expect(child1.siblings).to match_array([child2, child3])
    end

    it "is empty if the comment has no siblings" do
      parent = create(:comment, parent: create(:comment))
      child = create(:comment, parent: parent)

      expect(child.siblings).to be_empty
    end
  end
end

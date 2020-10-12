RSpec.describe "Admin manages tags" do
  let(:admin) { create(:user, :admin) }

  context "when an admin visits the admin tags index" do
    let(:page) { Admin::TagsIndexPage.new }

    it "sees available tags grouped by kind" do
      Tag.kinds.each_key { |kind| create(:"#{kind}_tag") }

      page.visit(as: admin)

      Tag.all.each do |tag|
        expect(page).to have_tag_table_row(tag)
      end
    end

    it "can add new tags by clicking the corresponding kind add link" do
      page.visit(as: admin).click_add_topic_tag

      expect(page).to have_current_path(new_admin_tag_path(kind: :topic))
      expect(page).to have_select("Kind", selected: "topic")
    end
  end

  context "when an admin fills out the new tag form" do
    let(:page) { Admin::CreateTagPage.new }

    context "when valid" do
      it "creates the tag and redirects the admin" do
        page.visit(as: admin).
          fill_in_id("foo-bar").
          select_tag_kind("topic").
          fill_in_description("Fun").
          submit_form

        expect(Tag.count).to eq(1)

        tag = Tag.first

        expect(tag.id).to eq("foo-bar")
        expect(tag).to be_topic
        expect(tag.description).to eq("Fun")
      end
    end

    context "when the ID is malformatted" do
      it "renders the error" do
      end
    end
  end

  context "when an admin fills out the edit tag form" do
    let(:tag) { create(:topic_tag) }
    let(:page) { Admin::EditTagPage.new(tag) }

    it "updates the tag" do
      page.visit(as: admin).
        select_tag_kind("meta").
        fill_in_description("beep").
        submit_form

      tag.reload

      expect(tag).to be_meta
      expect(tag.description).to eq("beep")
    end
  end
end

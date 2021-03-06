RSpec.describe FlattenedSubmissionSearch do
  let(:user) { create(:user) }

  describe "#results_paginator" do
    it "is a `ResultsPaginator`" do
      search = FlattenedSubmissionSearch.new({}, user)

      expect(search.results_paginator).to be_a(ResultsPaginator)
    end
  end

  describe "search results" do
    it "does not include submissions hidden by user" do
      present1, present2, hidden = create_list(:submission, 3, :text)
      create(:submission_action, :hidden, user: user, submission: hidden)

      search = FlattenedSubmissionSearch.new({}, user)
      results = search.results_paginator.results_page

      expect(results.map(&:id)).to match_array([present1.id, present2.id])
    end
  end

  describe "filtering" do
    context "when filtered by tag" do
      it "only returns submissions that have the given tag" do
        s1, = create_list(:submission, 2, :text)
        tag = create(:topic_tag)
        create(:submission_tag, submission: s1, tag: tag)

        search = FlattenedSubmissionSearch.new({ tag_id: tag.id }, user)
        results = search.results_paginator.results_page

        expect(results.map(&:id)).to match_array([s1.id])
      end
    end

    context "when filtered by user" do
      it "only returns submissions by the user with the given username" do
        s1, = create_list(:submission, 2, :text)

        search = FlattenedSubmissionSearch.new({ username: s1.user.username }, user)
        results = search.results_paginator.results_page

        expect(results.map(&:id)).to match_array([s1.id])
      end
    end

    context "when filtered by action" do
      it "only returns submissions corresponding with the action if the current user can view them" do
        s1, = create_list(:submission, 2, :text)
        create(:submission_action, :saved, submission: s1, user: user)

        search = FlattenedSubmissionSearch.new({ submission_action: "saved" }, user)
        results = search.results_paginator.results_page

        expect(results.map(&:id)).to match_array([s1.id])
      end

      it "does not show submissions with the action for other users" do
        s1, = create_list(:submission, 2, :text)
        action = create(:submission_action, :saved, submission: s1)

        search = FlattenedSubmissionSearch.new({ username: action.user.username, submission_action: "saved" }, user)
        results = search.results_paginator.results_page

        expect(results.map(&:id)).not_to match_array([s1.id])
      end
    end
  end
end

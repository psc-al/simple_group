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
end

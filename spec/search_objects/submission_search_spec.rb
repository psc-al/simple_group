RSpec.describe SubmissionSearch do
  describe "#results_pagination" do
    it "is a `ResultsPaginator`" do
      search = SubmissionSearch.new({})

      expect(search.results_paginator).to be_a(ResultsPaginator)
    end
  end
end

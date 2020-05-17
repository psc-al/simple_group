RSpec.describe ResultsPaginator do
  describe "#results_page" do
    it "properly offsets and limits the results" do
      s1, s2, s3 = create_list(:submission, 3)

      expect(ResultsPaginator.new(Submission.all, { page: 0, per_page: 3 }).results_page).to eq(
        [s1, s2, s3]
      )
      expect(ResultsPaginator.new(Submission.all, { page: 0, per_page: 1 }).results_page).to eq(
        [s1]
      )
      expect(ResultsPaginator.new(Submission.all, { page: 1, per_page: 1 }).results_page).to eq(
        [s2]
      )
      expect(ResultsPaginator.new(Submission.all, { page: 2, per_page: 1 }).results_page).to eq(
        [s3]
      )
    end
  end

  describe "#max_page" do
    it "is a function of the result count and `per_page`" do
      create_list(:submission, 3)

      results = ResultsPaginator.new(Submission.all, { page: 0, per_page: 1 })

      # three pages, started from 0
      expect(results.max_page).to be(2)
    end
  end

  describe "#offset" do
    context "when we're on the first page" do
      it "is 0" do
        results = ResultsPaginator.new(Submission.all, { page: 0, per_page: 25 })

        expect(results.offset).to be(0)
      end
    end

    context "when we're on literally any other page" do
      it "is the page number multipled by `per_page`" do
        results = ResultsPaginator.new(Submission.all, { page: 2, per_page: 69 })

        expect(results.offset).to be(138)
      end
    end
  end
end

module Api
  module V1
    module Comments
      class UpvotesController < BaseController
        def update
          find_or_initialize_vote.then do |vote|
            if vote.persisted?
              handle_existing_vote(vote)
            else
              handle_upvote(vote)
            end
          end
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end

        private

        def handle_existing_vote(vote)
          if vote.upvote?
            vote.destroy!
            render json: build_response(:removed), status: :ok
          else
            handle_upvote(vote)
          end
        end

        def handle_upvote(vote)
          vote.upvote!
          render json: build_response(:upvoted), status: :ok
        end

        def build_response(action)
          {
            short_id: params[:comment_short_id],
            action: action
          }
        end

        def find_or_initialize_vote
          comment = Comment.friendly.visible.joins(:submission).
            merge(Submission.visible).find(params[:comment_short_id])
          current_user.votes.comment.find_or_initialize_by(votable_id: comment.id)
        end
      end
    end
  end
end

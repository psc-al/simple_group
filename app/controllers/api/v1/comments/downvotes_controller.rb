module Api
  module V1
    module Comments
      class DownvotesController < BaseController
        def update
          find_or_initialize_vote.then do |vote|
            if comment.children.where(user_id: current_user.id).exists?
              handle_vote(vote)
            else
              render json: build_response(:rejected).
                merge(info: t(".comment_before_downvote")),
                status: :forbidden
            end
          end
        end

        private

        def handle_vote(vote)
          if vote.persisted?
            handle_existing_vote(vote)
          else
            handle_downvote(vote)
          end
        end

        def handle_existing_vote(vote)
          if vote.downvote?
            vote.destroy!
            render json: build_response(:removed), status: :ok
          else
            handle_downvote(vote)
          end
        end

        def handle_downvote(vote)
          vote.downvote!
          render json: build_response(:downvoted), status: :ok
        end

        def build_response(action)
          {
            short_id: params[:comment_short_id],
            action: action
          }
        end

        def comment
          @_comment ||= Comment.friendly.find(params[:comment_short_id])
        end

        def find_or_initialize_vote
          current_user.votes.comment.find_or_initialize_by(votable_id: comment.id)
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end
      end
    end
  end
end

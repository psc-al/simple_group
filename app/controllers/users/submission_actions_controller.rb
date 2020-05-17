module Users
  class SubmissionActionsController < ApplicationController
    def update
      if current_user.present?
        handle_request
      else
        head :forbidden
      end
    end

    private

    def handle_request
      action = current_user.submission_actions.find_or_initialize_by(submission_action_params)
      if action.persisted?
        action.destroy!
        text = t("submissions.submission_list_item.actions.default.#{action.kind}")
      else
        action.save!
        text = t("submissions.submission_list_item.actions.created.#{action.kind}")
      end

      render json: {
        status: status_for_action(action),
        text: text
      }
    end

    def submission_action_params
      params.require(:submission_action).permit(:submission_short_id, :kind)
    end

    def status_for_action(action)
      case action.kind.to_sym
      when :hidden
        hidden_action_status(action)
      when :saved
        saved_action_status(action)
      end
    end

    def hidden_action_status(action)
      if action.destroyed?
        :unhidden
      else
        :hidden
      end
    end

    def saved_action_status(action)
      if action.destroyed?
        :unsaved
      else
        :saved
      end
    end
  end
end

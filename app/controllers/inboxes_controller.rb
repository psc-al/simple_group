class InboxesController < AuthenticatedController
  def show
    @inbox_items = FlattenedInboxItem.where(user_id: current_user.id)
    binding.pry
  end
end

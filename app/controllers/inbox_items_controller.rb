class InboxItemsController < AuthenticatedController
  def update
    current_user.inbox_items.find(params[:id]).update(inbox_item_params)
    redirect_to inbox_path
  end

  private

  def inbox_item_params
    params.require(:inbox_item).permit(:read)
  end
end

module Admin
  class TagsController < BaseController
    def index
      @grouped_tags = Tag.order(:description).to_a.group_by(&:kind)
    end

    def new
      @tag = Tag.new(kind: params[:kind])
    end

    def edit
      @tag = Tag.find(params[:id])
    end

    def create
      @tag = Tag.create(create_tag_params)
      if @tag.errors.none?
        redirect_to admin_tags_path, notice: t(".success")
      else
        render :new
      end
    end

    def update
      @tag = Tag.find(params[:id])
      if @tag.update(update_tag_params)
        redirect_to admin_tags_path, notice: t(".success")
      else
        render :edit
      end
    end

    private

    def create_tag_params
      params.require(:tag).permit(:id, :kind, :description)
    end

    def update_tag_params
      params.require(:tag).permit(:kind, :description)
    end
  end
end

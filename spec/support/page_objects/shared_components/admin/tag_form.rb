module TagForm
  def fill_in_id(id)
    fill_in :tag_id, with: id
    self
  end

  def select_tag_kind(kind)
    select kind, from: "Kind"
    self
  end

  def fill_in_description(description)
    fill_in :tag_description, with: description
    self
  end
end

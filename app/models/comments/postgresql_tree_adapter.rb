# frozen_string_literal: true

module Comments
  module PostgresqlTreeAdapter
    extend ActiveSupport::Concern

    included do
      before_create :set_ancestry_path

      has_many :children, class_name: "Comment", foreign_key: :parent_id
    end

    def root_node?
      parent_id.nil?
    end

    def childless?
      children.none?
    end

    # the `@>` operator is asking "is the left an ancestor of the right?"
    def descendants
      self.class.where("? @> ancestry_path", ancestor_path)
    end

    def siblings
      # if the ancestry path is present, we want to find all nodes
      # with the same ancestry path. if it's not, then we have a
      # root node which cannot have siblings.
      # we exclude `self` from the resulting relation.
      if ancestry_path.present?
        self.class.where("? = ancestry_path", ancestry_path).where.not(id: id)
      else
        self.class.none
      end
    end

    private

    def set_ancestry_path
      if parent.present?
        prefix = (parent.ancestry_path.present? ? "#{parent.ancestry_path}." : "")
        self.ancestry_path = "#{prefix}#{parent.short_id}"
      end
    end

    def ancestor_path
      prefix = ancestry_path.present? ? "#{ancestry_path}." : ""
      "#{prefix}#{short_id}"
    end
  end
end

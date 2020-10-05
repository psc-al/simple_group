# frozen_string_literal: true

module VotingHelper
  def control_classes(votable, control_type, prefix: nil)
    classes = [control_type]
    kind_int = prefix.present? ? votable.send(:"#{prefix}_vote_kind") : votable.vote_kind
    if kind_int.present? && Vote.kinds.key(kind_int).to_sym == control_type
      classes << "#{control_type}d"
    end
    classes.join(" ")
  end
end

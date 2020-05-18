module Comments
  module TreeMethods
    extend ActiveSupport::Concern

    included do
      # TODO: add support for other db adapters
      case ActiveRecord::Base.connection.adapter_name.downcase
      when "postgresql"
        include PostgresqlTreeAdapter
      else
        raise "unsupported database adapter"
      end
    end
  end
end

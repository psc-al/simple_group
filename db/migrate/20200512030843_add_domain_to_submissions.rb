class AddDomainToSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_reference :submissions, :domain, null: true, index: false, foreign_key: true
    add_index :submissions, :domain_id, where: "domain_id IS NOT NULL"
  end
end

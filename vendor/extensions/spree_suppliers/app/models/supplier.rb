class Supplier < ActiveRecord::Base
  has_many :images, :as => :viewable, :order => :position, :dependent => :destroy
  has_one :user
  has_many :supplier_invoices
  has_and_belongs_to_many :taxons
  has_many :products
end

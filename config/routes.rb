GithubSuppliers::Application.routes.draw do

  root :to => "products#index"
  gem "spree_suppliers", :path => "vendor/extensions/spree_suppliers", :require => "spree_suppliers"





end

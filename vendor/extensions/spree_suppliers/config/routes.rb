Rails.application.routes.draw do
  # Add your extension routes here
  resources :suppliers
  resources :supplier_invoices
  resources :invoice_items

  namespace :admin do
    resources :products do
      resources :suppliers, :member => {:select => :post, :remove => :post}, :collection => {:available => :post, :selected => :get}
      member do
        get :publish
        get :unpublish
      end
    end
    resources :orders do
      resources :suppliers, :collection => {:line_items => :get}
    end
  end
end

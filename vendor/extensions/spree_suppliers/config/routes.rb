Rails.application.routes.draw do
  # Add your extension routes here
  resources :suppliers
  resources :supplier_invoices
  resources :invoice_items
end

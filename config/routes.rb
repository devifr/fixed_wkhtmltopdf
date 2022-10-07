Rails.application.routes.draw do
  root "home#index"
  get 'wicked_pdf', to: "home#wicked_pdf"
  get 'pdfkit', to: "home#pdfkit"
  get 'prawn', to: "home#prawn"
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

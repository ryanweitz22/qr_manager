Rails.application.routes.draw do
  devise_for :admin_users

  namespace :admin do
    root to: "qr_codes#index"

    resources :qr_codes do
      member do
        get :download_qr
        patch :archive
        patch :unarchive
      end
      collection do
        get :archived
      end
    end
  end

  get "/q/:slug", to: "redirects#show", as: :qr_redirect
  root to: redirect("/admin")
end

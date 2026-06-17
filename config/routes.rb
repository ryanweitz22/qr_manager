Rails.application.routes.draw do
  # Devise automatically creates all login/logout routes for AdminUser
  # This gives us:
  # GET  /admin_users/sign_in  -> shows the login form
  # POST /admin_users/sign_in  -> processes the login
  # DELETE /admin_users/sign_out -> logs the admin out
  devise_for :admin_users

  # The admin namespace groups all admin routes under /admin/
  # Everything inside here starts with /admin/
  namespace :admin do
    # /admin/ goes to the QR codes list
    root to: "qr_codes#index"

    # resources creates all 7 standard routes automatically:
    # GET    /admin/qr_codes            -> index  (list all QR codes)
    # GET    /admin/qr_codes/new        -> new    (show create form)
    # POST   /admin/qr_codes            -> create (save new QR code)
    # GET    /admin/qr_codes/:id        -> show   (show one QR code)
    # GET    /admin/qr_codes/:id/edit   -> edit   (show edit form)
    # PATCH  /admin/qr_codes/:id        -> update (save edits)
    # DELETE /admin/qr_codes/:id        -> destroy (delete QR code)
    resources :qr_codes do
      # Extra route for downloading the QR code as a PNG file
      member do
        get :download_qr
      end
    end
  end

  # Public QR redirect URL — no login required
  # This is the URL encoded into every QR code image
  # When someone scans the QR code their phone hits this URL
  # :slug is a variable that matches whatever comes after /q/
  # e.g. /q/business-card-qr -> slug = "business-card-qr"
  get "/q/:slug", to: "redirects#show", as: :qr_redirect

  # The homepage redirects everyone to the admin area
  root to: redirect("/admin")
end
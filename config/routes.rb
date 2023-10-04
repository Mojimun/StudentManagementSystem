Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'students',passwords: 'users/passwords'}
  devise_scope :user do
    get 'users/sign_in', to: 'users/sessions#new'
    post 'users/sign_in', to: 'users/sessions#create'
    get 'users/sign_out', to: 'users/sessions#destroy'
    get 'users/sign_up', to: 'users/registrations#new'
    post 'users/sign_up', to: 'users/registrations#create'
    get "student_home", to: 'students#index'
    get "add_subject", to: 'students#add_subject'
    patch "change_subject_request", to: 'students#change_subject_request'
    get "change_password", to: 'users/registrations#change_password'
    patch 'change_my_password', to: 'users/registrations#change_my_password'
    authenticated :user do
      root to: 'application#dashboard'
    end
    unauthenticated do
      root to: "users/sessions#new", as: nil
    end
  end
  
  get "admin_home", to: "admins#index"
  get "all_user", to: "admins#all_user"
  get "subject_wise_students_count", to: "admins#subject_wise_students_count"
  get "user_details", to: "admins#user_details"
  post "user_verify", to: "admins#user_verify"
  post "user_delete", to: "admins#user_delete"
  post "save_mass_data_upload", to: "admins#save_mass_data_upload" 
  post "add_student", to: "admins#add_student"
end

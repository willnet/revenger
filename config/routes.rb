Rails.application.routes.draw do
  root to: 'main#index'
  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'help' => 'main#help'
  get 'privacy' => 'main#privacy'
  get 'terms' => 'main#terms'

  resources :posts, except: :edit

  resource :review, only: [:show, :create] do
    get :next
    get :count
  end

  get 'user/retire' => 'users#retire'
  delete 'user' => 'users#destroy'

  devise_for :users, path: 'user', skip: [:registrations]

  devise_scope :user do
    resource :user, controller: 'registrations', except: %i(new show)

    get 'login' => 'devise/sessions#new'
    post 'login' => 'devise/sessions#create'
    get 'logout' => 'devise/sessions#destroy'
    get 'signup' => 'registrations#new'
  end

  scope 'user' do
    resource :duration, only: [:edit, :update]
    resource :reminder, only: [:edit, :update]
  end

  get 'api/dashboard' => 'dashboard_api#show'

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  mount MissionControl::Jobs::Engine, at: "/jobs"
  match '*path' => 'application#error404', via: :all
end

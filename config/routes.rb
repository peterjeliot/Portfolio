Rails.application.routes.draw do
  get "/", to: "static_pages#index"
  get "/tetris", to: "static_pages#tetris", as: :tetris
end

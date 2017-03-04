Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    mount Orchestrator::Engine => "/control", as: "control"
end

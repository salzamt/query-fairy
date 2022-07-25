Rails.application.routes.draw do
  mount QueryFairy::Engine => "/query_fairy"
end

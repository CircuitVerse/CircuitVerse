Commontator::Engine.routes.draw do
  resources :threads, only: [:show] do
    resources :comments, except: [:index, :destroy], shallow: true do
      member do
        put 'delete'
        put 'undelete'
        
        put 'upvote'
        put 'downvote'
        put 'unvote'
      end
    end
    
    member do
      get 'mentions' if Commontator.mentions_enabled

      put 'close'
      put 'reopen'
      
      put 'subscribe', to: 'subscriptions#subscribe'
      put 'unsubscribe', to: 'subscriptions#unsubscribe'
    end
  end
end

Commontator::Engine.routes.draw do
  resources :threads, only: [ :show ] do
    resources :comments, except: [ :index, :destroy ], shallow: true do
      member do
        put 'upvote'
        put 'downvote'
        put 'unvote'

        put 'delete'
        put 'undelete'
      end
    end

    member do
      get 'mentions' if Commontator.mentions_enabled

      put 'subscribe', to: 'subscriptions#subscribe'
      put 'unsubscribe', to: 'subscriptions#unsubscribe'

      put 'close'
      put 'reopen'
    end
  end
end

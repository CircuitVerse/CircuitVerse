module Error
  class NotFoundError < CustomError
    def initialize
      super(:you_cant_see_me, 404, 'You can\'t see me')
    end
  end
end

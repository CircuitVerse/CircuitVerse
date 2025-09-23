module Lookbook
  class MethodResolver < DataResolver
    MATCHER = /(:{1}([a-zA-Z_\d]+))$/
    MATCH_INDEX = 2

    def resolve(input)
      evaluate(input)
    end
  end
end

module Lookbook
  class EvalResolver < DataResolver
    MATCHER = /(\{\{\s?(.*)\s?\}\})$/
    MATCH_INDEX = 2

    def resolve(input)
      evaluate(input)
    end
  end
end

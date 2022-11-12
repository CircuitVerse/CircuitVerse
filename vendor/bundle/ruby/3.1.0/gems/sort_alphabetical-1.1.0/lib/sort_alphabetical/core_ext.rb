module Enumerable
  def sort_alphabetical
    SortAlphabetical.sort(self)
  end

  def sort_alphabetical_by(&block)
    SortAlphabetical.sort(self,&block)
  end
end
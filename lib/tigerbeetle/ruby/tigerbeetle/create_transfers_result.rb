module TigerBeetle
    class CreateTransfersResult
        attr_accessor :index, :result
      
        def initialize(index, result)
          @index = index
          @result = result
        end
    end
end

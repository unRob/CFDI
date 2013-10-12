class Float
  
  def to_s
    sprintf('%.2f', self)
  end
  
end

module CFDI

  class ElementoComprobante
    
    def initialize data={}
      #puts self.class
      data.each do |k,v|
        self.instance_variable_set "@#{k}", v
      end
    end
    
    def self.data
      @cadenaOriginal
    end

    def cadena_original
      params = []
      data = {}
      data = self.class.data
     # puts self.class.cadenaOriginal
      
      data.each {|key| params.push instance_variable_get('@'+key.to_s) }
      return params
    end
    
    def to_h
      Hash[*self.class.data.map { |v|
        [v, self.send(v)]
      }.flatten]
    end
    
  end

end
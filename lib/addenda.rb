module CFDI

  # Un concepto del comprobante
  class Addenda
   
    attr_accessor *[:nombre, :namespace, :xsd, :data]
    
    def initialize data={}
      #puts self.class
      data.each do |k,v|
        method = "#{k}=".to_sym
        next if !self.respond_to? method
        self.send method, v
      end
    end
    
  end #Addenda
  
end #CFDI
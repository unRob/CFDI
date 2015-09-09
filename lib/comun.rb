# # Mkay, quiero que mis floats tengan dos decimales a huevo
# class Float

#   # Lo que dice la clase
#   #
#   # @return [String] El string de este float con dos decimales
#   def to_s
#     sprintf('%.2f', self)
#   end

# end
# Y quiero que los strings no tengan espacios extraños
class String

  # Limpia whitespace de extremos y espacios repetidos
  #
  # @return [String] Una copia del string sin espacios extraños
  def squish
    dup.squish!
  end

  # Lo mismo que squish, pero destructivo
  #
  # @return [String] El string original sin espacios extraños
  def squish!
    strip!
    gsub!(/\s(\s+)/, ' ')
    self
  end

end

module CFDI


  # Un elemento del comprobante con métodos mágicos y especiales
  class ElementoComprobante


    # Crear este elemento y settear lo que le pasemos como hash en un tipo de dato adecuado
    # @param  data [Hash] Los datos para este elemento
    #
    # @return [CFDI::ElementoComprobante] El elemento creado
    def initialize data={}
      #puts self.class
      data.each do |k,v|
        method = "#{k}=".to_sym
        next if !self.respond_to? method
        self.send method, v
      end
    end


    # Los elementos para generar la cadena original de este comprobante
    #
    # @return [Array] idem
    def self.data
      @cadenaOriginal
    end


    # Un array con los datos de la cadena original para este elemento
    #
    # @return [Array] idem
    def cadena_original
      params = []
      data = {}
      data = self.class.data
     # puts self.class.cadenaOriginal

      data.each {|key| params.push instance_variable_get('@'+key.to_s) }
      return params
    end


    # Los datos xmleables de este elemento
    #
    # @return [Hash] idem
    def to_h
      h = {}
      self.class.data.each do |v|
        value = self.send(v)
        value = value.to_h if value.is_a? ElementoComprobante
        h[v] = value
      end

      h
    end

  end

end

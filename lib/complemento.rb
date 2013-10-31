module CFDI

  # Un complemento fiscal, o Timbre
  class Complemento < ElementoComprobante
    
    # los datos del timbre
    @cadenaOriginal = [:UUID, :FechaTimbrado, :selloCFD, :noCertificadoSAT, :selloSAT, :version]
    attr_accessor *@cadenaOriginal
    
    # Regresa la cadena Original del Timbre Fiscal Digital del SAT
    #
    # @return [String] la cadena formada
    def cadena
      return "||#{version}|#{@UUID}|#{@FechaTimbrado}|#{selloCFD}|#{noCertificadoSAT}||"
    end
    
  end

end
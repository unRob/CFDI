module CFDI

  class Complemento < ElementoComprobante
    
    @cadenaOriginal = [:UUID, :FechaTimbrado, :selloCFD, :noCertificadoSAT, :selloSAT, :version]
    attr_accessor *@cadenaOriginal
    
  end

end
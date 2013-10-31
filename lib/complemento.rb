module CFDI

  # Un complemento fiscal, o Timbre
  class Complemento < ElementoComprobante
    
    # los datos del timbre
    @cadenaOriginal = [:UUID, :FechaTimbrado, :selloCFD, :noCertificadoSAT, :selloSAT, :version]
    attr_accessor *@cadenaOriginal
    
  end

end
module CFDI
  
  class Entidad < ElementoComprobante
    @cadenaOriginal = [:rfc, :nombre, :domicilioFiscal, :expedidoEn, :regimenFiscal]
    @data = @cadenaOriginal
    attr_accessor *@cadenaOriginal
    
    def cadena_original
      expedido = @expedidoEn ? @expedidoEn.cadena_original : nil
      return [
        @rfc,
        @nombre,
        *@domicilioFiscal.cadena_original,
        expedido,
        @regimenFiscal
      ].flatten
    end
    
    def ns
      return ({
        nombre: @nombre,
        rfc: @rfc
      })
    end
    
  end
  
  class Domicilio < ElementoComprobante
    @cadenaOriginal = [:calle, :noExterior, :noInterior, :colonia, :localidad, :referencia, :municipio, :estado, :pais, :codigoPostal]
    attr_accessor *@cadenaOriginal
    
  end
  
end
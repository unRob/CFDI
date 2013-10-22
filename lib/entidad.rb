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
    
    def domicilioFiscal= domicilio
      domicilio = Domicilio.new domicilio unless domicilio.is_a? Domicilio
      @domicilioFiscal = domicilio
    end
    
    def expedidoEn= domicilio
      return if !domicilio
      domicilio = Domicilio.new domicilio unless domicilio.is_a? Domicilio
      @expedidoEn = domicilio
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
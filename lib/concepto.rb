module CFDI

  class Concepto < ElementoComprobante
    
    @cadenaOriginal = [:cantidad, :unidad, :noIdentificacion, :descripcion, :valorUnitario, :importe]
    #@data = @cadenaOriginal
    attr_accessor *@cadenaOriginal
    
    def cadena_original
      return [
        @cantidad.to_i,
        @unidad,
        @noIdentificacion,
        @descripcion,
        @valorUnitario,
        @importe
      ]
    end
    
    def valorUnitario= vu
      @valorUnitario = vu.to_f
    end
    
    def importe
      return @valorUnitario*@cantidad
    end
    
  end

end
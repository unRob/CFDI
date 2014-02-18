module CFDI

  # Un concepto del comprobante
  class Concepto < ElementoComprobante
    
    # @private
    @cadenaOriginal = [:cantidad, :unidad, :noIdentificacion, :descripcion, :valorUnitario, :importe]
    # @private
    attr_accessor *@cadenaOriginal
    
    # @private
    def cadena_original
      return [
        @cantidad.to_i,
        @unidad,
        @noIdentificacion,
        @descripcion,
        self.valorUnitario,
        self.importe
      ]
    end
    
    # Asigna la descripción de un concepto
    # @param descricion [String] La descripción del concepto
    #
    # @return [String] La descripción como string sin espacios extraños
    def descripcion= descripcion
      @descripcion = descripcion.squish
      @descripcion
    end

    # Asigna el valor unitario de este concepto
    # @param  dineros [String, Float, #to_f] Cualquier cosa que responda a #to_f
    # 
    # @return [Float] El valor unitario como Float
    def valorUnitario= dineros
      @valorUnitario = dineros.to_f
      @valorUnitario
    end


    # El importe de este concepto
    # 
    # @return [Float] El valor unitario multiplicado por la cantidad
    def importe
      return @valorUnitario*@cantidad
    end


    # Asigna la cantidad de (tipo) de este concepto
    # @param  qty [Integer, String, #to_i] La cantidad, que ahuevo queremos en int, porque no, no podemos vender 1.5 Kilos de verga...
    # 
    # @return [Integer] La cantidad
    def cantidad= qty
      @cantidad = qty.to_i
      @cantidad
    end
    
  end

end
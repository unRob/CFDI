module CFDI
  class Impuestos < ElementoComprobante

    # @private
    @cadenaOriginal = [:totalImpuestosTrasladados, :traslados]
    # @private
    attr_accessor *@cadenaOriginal

    def initialize
      @traslados = []
    end

    # Asigna el total de impuestos trasladados
    # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
    def totalImpuestosTrasladados=(valor)
      @totalImpuestosTrasladados = valor.to_f
    end

    # @return [Integer] La cantidad de impuestos que tiene.
    def count
      traslados.count
    end

    class Traslado < ElementoComprobante
      # @private
      @cadenaOriginal = [:impuesto, :tasa, :importe]
      # @private
      attr_accessor *@cadenaOriginal
    end

  end
end

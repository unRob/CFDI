module CFDI
  class Impuestos < ElementoComprobante

    # @private
    @cadenaOriginal = [:totalImpuestosTrasladados, :totalImpuestosRetenidos, :traslados, :retenciones]
    # @private
    attr_accessor *@cadenaOriginal

    def initialize
      @traslados = []
      @retenciones = []
    end

    # Asigna el total de impuestos trasladados
    # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
    def totalImpuestosTrasladados valor
      @totalImpuestosTrasladados = valor.to_f
    end

    # Asigna el total de impuestos retenidos
    # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
    def totalImpuestosRetenidos valor
      @totalImpuestosRetenidos = valor.to_f
    end

    # @return [Integer] La cantidad de impuestos que tiene.
    def count
      traslados.count + retenciones.count
    end
  end


  class ImpuestoGenerico < ElementoComprobante
    # @private
    @cadenaOriginal = [:impuesto, :tasa, :importe]
    # @private
    attr_accessor *@cadenaOriginal

    # Asigna la tasa del impuesto
    # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
    def tasa= valor
      @tasa = valor.to_f
    end

    # Asigna el importe del impuesto
    # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
    def importe= valor
      @importe = valor.to_f
    end
  end


  class Traslado < ImpuestoGenerico
  end


  class Retencion < ImpuestoGenerico
  end
end

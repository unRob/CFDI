module CFDI
  class Impuestos < ElementoComprobante

    # @private
    @cadenaOriginal = [:totalImpuestosTrasladados, :totalImpuestosRetenidos, :traslados, :retenciones]
    # @private
    attr_accessor(*@cadenaOriginal)

    def initialize data={}
      self.traslados = data[:traslados] || []
      self.retenciones = data[:retenciones] || []
      self.totalImpuestosTrasladados = data[:totalImpuestosTrasladados] if data[:totalImpuestosTrasladados]
      self.totalImpuestosRetenidos = data[:totalImpuestosRetenidos] if data[:totalImpuestosRetenidos]
    end

    def traslados= value
      @traslados = value.map { |t|
        t.is_a?(ImpuestoGenerico) ? t : Impuestos::Traslado.new({
          tasa: t[:tasa],
          impuesto: t[:impuesto] || 'IVA',
          importe: t[:importe]
        })
      }
      @totalImpuestosTrasladados = suma(:traslados) if @traslados.count > 0
    end

    def retenciones= value
      @retenciones = value.map { |t|
        t.is_a?(ImpuestoGenerico) ? t : Impuestos::Retencion.new({
          tasa: t[:tasa],
          impuesto: t[:impuesto] || 'IVA',
          importe: t[:importe]
        })
      }
      @totalImpuestosRetenidos = suma(:retenciones) if @retenciones.count > 0
    end


    # Asigna el total de impuestos trasladados
    # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
    def totalImpuestosTrasladados= valor
      @totalImpuestosTrasladados = valor.to_f
    end

    # Asigna el total de impuestos retenidos
    # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
    def totalImpuestosRetenidos= valor
      @totalImpuestosRetenidos = valor.to_f
    end

    # @return [Integer] La cantidad de impuestos que tiene.
    def count
      traslados.count + retenciones.count
    end

    def suma tipo_impuestos
      instance_variable_get("@#{tipo_impuestos}").map(&:importe).reduce(0.0, &:+)
    end

    # @return [Float] la suma de traslados menos retenciones
    def total
      suma(:traslados) - suma(:retenciones)
    end


    class ImpuestoGenerico < ElementoComprobante
      # @private
      @cadenaOriginal = [:impuesto, :tasa, :importe]
      # @private
      attr_accessor(*@cadenaOriginal)

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
      # @private
      @cadenaOriginal = [:impuesto, :tasa, :importe]
      # @private
      attr_accessor(*@cadenaOriginal)

      # # Asigna la tasa del impuesto
      # # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
      # def tasa= valor
      #   @tasa = valor.to_f
      # end

      # # Asigna el importe del impuesto
      # # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
      # def importe= valor
      #   @importe = valor.to_f
      # end
    end


    class Retencion < ImpuestoGenerico
      # @private
      @cadenaOriginal = [:impuesto, :tasa, :importe]
      # @private
      attr_accessor(*@cadenaOriginal)

      # # Asigna la tasa del impuesto
      # # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
      # def tasa= valor
      #   @tasa = valor.to_f
      # end

      # # Asigna el importe del impuesto
      # # @param  valor [String, Float, #to_f] Cualquier objeto que responda a #to_f
      # def importe= valor
      #   @importe = valor.to_f
      # end
    end
  end

end

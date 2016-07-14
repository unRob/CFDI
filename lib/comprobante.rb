module CFDI
  # La clase principal para crear Comprobantes
  class Comprobante

    # los datos para la cadena original en el órden correcto
    # @private
    @@datosCadena = [:version, :fecha, :tipoDeComprobante, :formaDePago, :condicionesDePago, :subTotal, :TipoCambio, :moneda, :total, :metodoDePago, :lugarExpedicion, :NumCtaPago]
    # Todos los datos del comprobante
    # @private
    @@data = @@datosCadena+[:emisor, :receptor, :conceptos, :serie, :folio, :sello, :noCertificado, :certificado, :conceptos, :complemento, :cancelada, :impuestos]
    attr_accessor(*@@data)

    @addenda = nil

    @@options = {
      tasa: 0.16,
      defaults: {
        moneda: 'pesos',
        version: '3.3',
        subTotal: 0.0,
        TipoCambio: 1,
        conceptos: [],
        impuestos: Impuestos.new,
        tipoDeComprobante: 'ingreso'
      }
    }

    # Configurar las opciones default de los comprobantes
    #
    # == Parameters:
    # options::
    #  Las opciones del comprobante: tasa (de impuestos), defaults: un Hash con la moneda (pesos), version (3.2), TipoCambio (1), y tipoDeComprobante (ingreso)
    #
    # @return [Hash]
    #
    def self.configure options
      @@options = Comprobante.rmerge @@options, options
      @@options
    end

    # Crear un comprobante nuevo
    #
    # @param  data [Hash] Los datos de un comprobante
    # @option data [String] :version ('3.2') La version del CFDI
    # @option data [String] :fecha ('') La fecha del CFDI
    # @option data [String] :tipoDeComprobante ('ingreso') El tipo de Comprobante
    # @option data [String] :formaDePago ('') La forma de pago (pago en una sóla exhibición?)
    # @option data [String] :condicionesDePago ('') Las condiciones de pago (Efectos fiscales al pago?)
    # @option data [String] :TipoCambio (1) El tipo de cambio para la moneda de este CFDI'
    # @option data [String] :moneda ('pesos') La moneda de pago
    # @option data [String] :metodoDePago ('') El método de pago (depósito bancario? efectivo?)
    # @option data [String] :lugarExpedicion ('') El lugar dónde se expide la factura (Nutopía, México?)
    # @option data [String] :NumCtaPago (nil) El número de cuenta para el pago
    #
    # @param  options [Hash] Las opciones para este comprobante
    # @see [Comprobante@@options] Opciones
    #
    # @return {CFDI::Comprobante}
    def initialize data={}, options={}
      #hack porque dup se caga con instance variables
      opts = Marshal::load(Marshal.dump(@@options))
      data = opts[:defaults].merge data
      @opciones = opts.merge options
      data.each do |k,v|
        method = "#{k}="
        next if !self.respond_to?(method)
        self.send method, v
      end
      @impuestos ||= Impuestos.new
    end


    def addenda= addenda
      addenda = Addenda.new addenda unless addenda.is_a? Addenda
      @addenda = addenda
    end


    # Regresa el método de pago como valor textual
    #
    # En la versión 3.3 del CFDI el SAT decidió salir con sus pendejadas y cambiar la manera de
    # almacenar el método de pago como una clave porque les salió lo contador old school. Claro
    # se guarda como una cadena de texto porque 0.1 + 0.2 ~= 0.30000000000000004 y para que sus
    # archivos de excel estén centrados. Pensamientos positivos, Roberto, respira profundo.
    #
    # @return [String] El metodo de pago textual, por ejemplo "Dinero electrónico"
    def metodoDePago_value
      if @version.to_f >= 3.3
        CFDI.metodos_de_pago @metodoDePago
      else
        @metodoDePago
      end
    end

    # Regresa el subtotal de este comprobante, tomando el importe de cada concepto
    #
    # @return [Float] El subtotal del comprobante
    def subTotal
      ret = 0
      @conceptos.each do |c|
        ret += c.importe
      end
      ret
    end

    # Regresa el total
    #
    # @return [Float] El subtotal multiplicado por la tasa
    def total
      iva = 0.0
      iva = (self.subTotal*@opciones[:tasa]) if @impuestos.count > 0
      self.subTotal + @impuestos.total
    end

    def impuestos= value
      @impuestos = case @version
        when '3.2'
          return value if value.is_a? Impuestos
          raise 'v3.2 CFDI impuestos must be an array of hashes' unless value.is_a? Array

          traslados = value.map {|i|
            raise 'v3.2 CFDI impuestos must be an array of hashes' unless i.is_a? Hash

            tasa = i[:tasa] || @opciones[:tasa]

            {
              tasa: tasa,
              impuesto: i[:impuesto] || 'IVA',
              importe: tasa * self.subTotal
            }
          }

          Impuestos.new({ traslados: traslados })
        when '3.3' then value.is_a?(Impuestos) ? value : Impuestos.new(value)
      end
    end

    # Asigna un emisor de tipo {CFDI::Entidad}
    # @param  emisor [Hash, CFDI::Entidad] Los datos de un emisor
    #
    # @return [CFDI::Entidad] Una entidad
    def emisor= emisor
      emisor = Entidad.new emisor unless emisor.is_a? Entidad
      @emisor = emisor;
    end

    # Asigna un receptor
    # @param  receptor [Hash, CFDI::Entidad] Los datos de un receptor
    #
    # @return [CFDI::Entidad] Una entidad
    def receptor= receptor
      receptor = Entidad.new receptor unless receptor.is_a? Entidad
      @receptor = receptor;
      receptor
    end

    # Agrega uno o varios conceptos
    # @param  conceptos [Array, Hash, CFDI::Concepto] Uno o varios conceptos
    #
    # En caso de darle un Hash o un {CFDI::Concepto}, agrega este a los conceptos, de otro modo, sobreescribe los conceptos pre-existentes
    #
    # @return [Array] Los conceptos de este comprobante
    def conceptos= conceptos
      if conceptos.is_a? Array
        conceptos.map! do |concepto|
          concepto = Concepto.new concepto unless concepto.is_a? Concepto
        end
      elsif conceptos.is_a? Hash
        conceptos << Concepto.new(concepto)
      elsif conceptos.is_a? Concepto
        conceptos << conceptos
      end

      @conceptos = conceptos
      conceptos
    end


    # Asigna un complemento al comprobante
    # @param  complemento [Hash, CFDI::Complemento] El complemento a agregar
    #
    # @return [CFDI::Complemento]
    def complemento= complemento
      complemento = Complemento.new complemento unless complemento.is_a? Complemento
      @complemento = complemento
      complemento
    end


    # Asigna una fecha al comprobante
    # @param  fecha [Time, String] La fecha y hora (YYYY-MM-DDTHH:mm:SS) de la emisión
    #
    # @return [String] la fecha en formato '%FT%R:%S'
    def fecha= fecha
      fecha = fecha.strftime('%FT%R:%S') unless fecha.is_a? String
      @fecha = fecha
    end


    # El comprobante como XML
    #
    # @return [String] El comprobante namespaceado en versión 3.2 (porque soy un huevón)
    def to_xml
      ns = {
        'xmlns:cfdi' => "http://www.sat.gob.mx/cfd/3",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' => "http://www.sat.gob.mx/cfd/3 http://www.sat.gob.mx/sitio_internet/cfd/3/cfdv#{@version.gsub(/\D/, '')}.xsd",
        version: @version,
        folio: @folio,
        fecha: @fecha,
        formaDePago: @formaDePago,
        condicionesDePago: @condicionesDePago,
        subTotal: sprintf('%.2f', self.subTotal),
        Moneda: @moneda,
        total: sprintf('%.2f', self.total),
        metodoDePago: @metodoDePago,
        tipoDeComprobante: @tipoDeComprobante,
        LugarExpedicion: @lugarExpedicion,
      }
      ns[:serie] = @serie if @serie
      ns[:TipoCambio] = @TipoCambio if @TipoCambio
      ns[:NumCtaPago] = @NumCtaPago if @NumCtaPago && @NumCtaPago!=''

      if (@addenda)
        # Si tenemos addenda, entonces creamos el campo "xmlns:ElNombre" y agregamos sus definiciones al SchemaLocation
        ns["xmlns:#{@addenda.nombre}"] = @addenda.namespace
        ns['xsi:schemaLocation'] += ' '+[@addenda.namespace, @addenda.xsd].join(' ')
      end

      if @noCertificado
        ns[:noCertificado] = @noCertificado
        ns[:certificado] = @certificado
      end

      if @sello
        ns[:sello] = @sello
      end

      @builder = Nokogiri::XML::Builder.new do |xml|
        xml.Comprobante(ns) do
          ins = xml.doc.root.add_namespace_definition('cfdi', 'http://www.sat.gob.mx/cfd/3')
          xml.doc.root.namespace = ins

          xml.Emisor(@emisor.ns)  {
            xml.DomicilioFiscal(@emisor.domicilioFiscal.to_h.reject {|k,v| v == nil})
            xml.ExpedidoEn(@emisor.expedidoEn.to_h.reject {|k,v| v == nil || v == ''})
            xml.RegimenFiscal({Regimen: @emisor.regimenFiscal})
          }
          xml.Receptor(@receptor.ns) {
            xml.Domicilio(@receptor.domicilioFiscal.to_h.reject {|k,v| v == nil || v == ''})
          }
          xml.Conceptos {
            @conceptos.each do |concepto|
              # select porque luego se caga el xml si incluyo noIdentificacion y es empty

              cc = concepto.to_h.select {|k,v| v!=nil && v != ''}

              cc = cc.map {|k,v|
                v = sprintf('%.2f', v) if v.is_a? Float
                [k,v]
              }.to_h

              xml.Concepto(cc) {
                xml.ComplementoConcepto
              }
            end
          }

          impuestos_options = {}
          impuestos_options = {totalImpuestosTrasladados: sprintf('%.2f', self.subTotal*@opciones[:tasa])} if @impuestos.count > 0
          xml.Impuestos(impuestos_options) {
            if @impuestos.traslados.count > 0
              xml.Traslados {
                @impuestos.traslados.each do |traslado|
                  xml.Traslado({
                    impuesto: traslado.impuesto,
                    tasa:(@opciones[:tasa]*100).to_i,
                    importe: sprintf('%.2f', self.subTotal*@opciones[:tasa])})
                end
              }
            end
            if @impuestos.retenciones.count > 0
              xml.Retenciones {
                @impuestos.retenciones.each do |retencion|
                  xml.Retencion({
                    impuesto: retencion.impuesto,
                    tasa:(@opciones[:tasa]*100).to_i,
                    importe: sprintf('%.2f', self.subTotal*@opciones[:tasa])})
                end
              }
            end
          }

          xml.Complemento {
            if @complemento
              nsTFD = {
                'xsi:schemaLocation' => 'http://www.sat.gob.mx/TimbreFiscalDigital http://www.sat.gob.mx/TimbreFiscalDigital/TimbreFiscalDigital.xsd',
                'xmlns:tfd' => 'http://www.sat.gob.mx/TimbreFiscalDigital',
                'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
              }
              xml['tfd'].TimbreFiscalDigital(@complemento.to_h.merge nsTFD) {
              }

            end
          }

          if (@addenda)
            xml.Addenda {
              @addenda.data.each do |k,v|
                if v.is_a? Hash
                  xml[@addenda.nombre].send(k, v)
                elsif v.is_a? Array
                  xml[@addenda.nombre].send(k, v)
                else
                  xml[@addenda.nombre].send(k, v)
                end
              end
            }
          end

        end
      end
      @builder.to_xml
    end


    # Un hash con todos los datos del comprobante, listo para Hash.to_json
    #
    # @return [Hash] El comprobante como Hash
    def to_h
      hash = {}
      @@data.each do |key|
        data = deep_to_h send(key)
        hash[key] = data
      end

      return hash
    end


    # La cadena original del CFDI
    #
    # @return [String] Separada por pipes, because fuck you that's why
    def cadena_original
      params = []

      @@datosCadena.each {|key| params.push send(key) }
      params += @emisor.cadena_original
      params << @regimen
      params += @receptor.cadena_original

      @conceptos.each do |concepto|
        params += concepto.cadena_original
      end

      if @impuestos.count > 0
        @impuestos.traslados.each do |traslado|
          # tasa = traslado.tasa ? traslado.tasa.to_i : (@opciones[:tasa]*100).to_i
          tasa = (@opciones[:tasa]*100).to_i
          total = self.subTotal*@opciones[:tasa]
          params += [traslado.impuesto, tasa, total, total]
        end
      end

      params.select! { |i| i != nil && i != '' }
      params.map! do |elem|
        if elem.is_a? Float
          elem = sprintf('%.2f', elem)
        else
          elem = elem.to_s
        end
        elem
      end

      return "||#{params.join '|'}||"
    end


    # Revisa que el timbre de un comprobante sea válido
    # @param [String] El certificado del PAC
    #
    # @return [Boolean] El resultado de la validación
    def timbre_valido? cert=nil
      return false unless complemento && complemento.selloSAT

      unless cert
        require 'open-uri'
        comps = complemento.noCertificadoSAT.scan(/(\d{6})(\d{6})(\d{2})(\d{2})(\d{2})?/)
        base_url = 'ftp://ftp2.sat.gob.mx/Certificados/FEA'
        url = "#{base_url}/#{comps.join('/')}/#{cert}.cer"
        begin
          cert = open(url).read
        rescue Exception => e
          raise "No pude descargar el certificado <#{url}>: #{e}"
        end
      end

      cert = OpenSSL::X509::Certificate.new cert
      selloBytes = Base64::decode64(complemento.selloSAT)
      cert.public_key.verify(OpenSSL::Digest::SHA1.new, selloBytes, complemento.cadena)
    end


    # @private
    def self.rmerge defaults, other_hash
      result = defaults.merge(other_hash) do |key, oldval, newval|
        oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
        newval = newval.to_hash if newval.respond_to?(:to_hash)
        oldval.class.to_s == 'Hash' && newval.class.to_s == 'Hash' ? Comprobante.rmerge(oldval, newval) : newval
      end
      result
    end

  private

  def deep_to_h value
    if value.is_a? ElementoComprobante
      original = value.to_h
      value = {}
      original.each do |k,v|
        value[k] = deep_to_h v
      end
    elsif value.is_a?(Array)
      value = value.map do |v|
        deep_to_h v
      end
    end
    value
  end

  end
end

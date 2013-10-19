module CFDI
  class Comprobante
  
    @@datosCadena = [:version, :fecha, :tipoDeComprobante, :formaDePago, :condicionesDePago, :subTotal, :moneda, :total, :metodoDePago, :lugarExpedicion]
    @@data = @@datosCadena+[:emisor, :receptor, :conceptos, :serie, :folio, :sello, :noCertificado, :certificado, :impuestos, :complemento, :NumCtaPago, :TipoCambio]
    attr_accessor *@@data
  
    @@options = {
      tasa: 0.16,
      defaults: {
        moneda: 'pesos',
        version: '3.2',
        subTotal: 0.0,
        conceptos: [],
        impuestos: [],
        tipoDeComprobante: 'ingreso'
      }
    }
  
    def configure (options)
      @@options.merge! options
    end
  
    def initialize (data={}, options={})
      data = @@options[:defaults].merge data
      @opciones = @@options.merge options
      data.each do |k,v|
        self.send "#{k}=", v
      end
    end
  
    def subTotal
      ret = 0
      @conceptos.each do |c|
        ret += c.importe
      end
      ret
    end
  
    def total
      self.subTotal+(self.subTotal*@opciones[:tasa])
    end
    
    def emisor= emisor 
      emisor = Entidad.new emisor unless emisor.is_a? Entidad
      @emisor = emisor;
    end
    
    def receptor= receptor 
      receptor = Entidad.new receptor unless receptor.is_a? Entidad
      @receptor = receptor;
    end
    
    def conceptos= conceptos
      if conceptos.is_a? Array
        conceptos.map! do |concepto|
          concepto = Concepto.new concepto unless concepto.is_a? Concepto
        end
      elsif conceptos.is_a? Hash
        conceptos = [Concepto.new(concepto)]
      elsif conceptos.is_a? Concepto
        conceptos = [conceptos]
      end
      
      @conceptos = conceptos
    end
    
    def complemento= complemento
      complemento = Complemento.new complemento unless complemento.is_a? Complemento
      @complemento = complemento
    end
  
    def fecha= fecha
      fecha = fecha.strftime('%FT%R:%S') unless fecha.is_a? String
      @fecha = fecha
    end
  
    def to_xml
      ns = {
        'xmlns:cfdi' => "http://www.sat.gob.mx/cfd/3",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' => "http://www.sat.gob.mx/cfd/3 http://www.sat.gob.mx/sitio_internet/cfd/3/cfdv32.xsd",
        version: @version,
        folio: @folio,
        fecha: @fecha,
        formaDePago: @formaDePago,
        condicionesDePago: @condicionesDePago,
        subTotal: self.subTotal,
        Moneda: @moneda,
        total: self.total,
        metodoDePago: @metodoDePago,
        tipoDeComprobante: @tipoDeComprobante,
        LugarExpedicion: @lugarExpedicion,
      }
      ns[:serie] = @serie if @serie
      ns[:serie] = @TipoCambio if @TipoCambio
    
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
            xml.ExpedidoEn(@emisor.expedidoEn.to_h.reject {|k,v| v == nil})
            xml.RegimenFiscal({Regimen: @emisor.regimenFiscal})
          }
          xml.Receptor(@receptor.ns) {
            xml.Domicilio(@receptor.domicilioFiscal.to_h.reject {|k,v| v == nil})
          }
          xml.Conceptos {
            @conceptos.each do |concepto|
              xml.Concepto(concepto.to_h) {
                xml.ComplementoConcepto
              }
            end
          }
          xml.Impuestos({totalImpuestosTrasladados: self.subTotal*@opciones[:tasa]}) {
            xml.Traslados {
              @impuestos.each do |impuesto|
                 xml.Traslado({impuesto: impuesto[:impuesto], tasa:@opciones[:tasa]*100.to_i, importe: self.subTotal*@opciones[:tasa]})
              end
            }
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
        end
      end
      @builder.to_xml
    end
  
    def to_h
      hash = {}
      @@data.each do |key|
        data = deep_to_h send(key)
        hash[key] = data
      end
      
      return hash
    end
  
    def cadena_original
      params = []
    
      @@datosCadena.each {|key| params.push send(key) }      
      params += @emisor.cadena_original
      params << @regimen
      params += @receptor.cadena_original
    
      @conceptos.each do |concepto|
        params += concepto.cadena_original
      end
    
      @impuestos.each do |traslado|
        params += [traslado[:impuesto], @opciones[:tasa]*100, self.subTotal*@opciones[:tasa], self.subTotal*@opciones[:tasa]]
      end
    
      params.select! { |i| i != nil }
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
      
      #value = value.to_h if value.respond_to? :to_h
      #if value.each do |vi|
      #  value.map do |k,v|
      #    v = deep_to_h v
      #  end
      #end
      value
    end
  
  end
end
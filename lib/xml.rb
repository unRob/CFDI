module CFDI

  def self.from_xml(data)
    xml = Nokogiri::XML(data);
    xml.remove_namespaces!
    factura = Comprobante.new
    
    comprobante = xml.at_xpath('//Comprobante')
    emisor = xml.at_xpath('//Emisor')
    de = emisor.at_xpath('//DomicilioFiscal')
    exp = emisor.at_xpath('//ExpedidoEn')
    receptor = xml.at_xpath('//Receptor')
    dr = receptor.at_xpath('//Domicilio')
    
    factura.version = comprobante.attr('version')
    factura.serie = comprobante.attr('serie')
    factura.folio = comprobante.attr('folio')
    factura.fecha = Time.parse(comprobante.attr('fecha'))
    factura.noCertificado = comprobante.attr('noCertificado')
    factura.certificado = comprobante.attr('certificado')
    factura.sello = comprobante.attr('sello')
    #factura.subTotal = comprobante.attr('subTotal').to_f
    factura.formaDePago = comprobante.attr('formaDePago')
    factura.condicionesDePago = comprobante.attr('condicionesDePago')
    factura.tipoDeComprobante = comprobante.attr('tipoDeComprobante')
    factura.lugarExpedicion = comprobante.attr('LugarExpedicion')
    factura.metodoDePago = comprobante.attr('metodoDePago')
    factura.moneda = comprobante.attr('Moneda')
    
    
   

    emisor = {
      rfc: emisor.attr('rfc'),
      nombre: emisor.attr('nombre'),
      regimenFiscal: emisor.at_xpath('//RegimenFiscal').attr('Regimen'),
      domicilioFiscal: {
        calle: de.attr('calle'),
        noExterior: de.attr('noExterior'),
        noInterior: de.attr('noInterior'),
        colonia: de.attr('colonia'),
        localidad: de.attr('localidad'),
        referencia: de.attr('referencia'),
        municipio: de.attr('municipio'),
        estado: de.attr('estado'),
        pais: de.attr('pais'),
        cp: de.attr('codigoPostal')
      }
    }
    
    if exp
      emisor[:expedidoEn] = {
        calle: exp.attr('calle'),
        no_ext: exp.attr('noExterior'),
        no_int: exp.attr('noInterior'),
        colonia: exp.attr('colonia'),
        localidad: exp.attr('localidad'),
        referencia: exp.attr('referencia'),
        municipio: exp.attr('municipio'),
        estado: exp.attr('estado'),
        pais: exp.attr('pais'),
        cp: exp.attr('codigoPostal')
      }
    end
    
    factura.emisor = emisor;
    
    factura.receptor = {
      rfc: receptor.attr('rfc'),
      nombre: receptor.attr('nombre'),
      domicilioFiscal: {
        calle: dr.attr('calle'),
        no_ext: dr.attr('noExterior'),
        no_int: dr.attr('noInterior'),
        colonia: dr.attr('colonia'),
        localidad: dr.attr('localidad'),
        referencia: dr.attr('referencia'),
        municipio: dr.attr('municipio'),
        estado: dr.attr('estado'),
        pais: dr.attr('pais'),
        cp: dr.attr('codigoPostal')
      }
    }
    
    
    xml.xpath('//Concepto').each do |concepto|
      total = concepto.attr('importe').to_f
      factura.conceptos << Concepto.new({
        cantidad: concepto.attr('cantidad').to_f,
        unidad: concepto.attr('unidad'),
        noIdentificacion: concepto.attr('noIdentificacion'),
        descripcion: concepto.attr('descripcion'),
        valorUnitario: concepto.attr('valorUnitario').to_f
      })
    end
    
    
    
    timbre = xml.at_xpath('//TimbreFiscalDigital')
    if timbre
      version = timbre.attr('version');
      uuid = timbre.attr('UUID')
      fecha = timbre.attr('FechaTimbrado')
      sello = timbre.attr('selloCFD')
      certificado = timbre.attr('noCertificadoSAT')
      factura.complemento = {
        UUID: uuid,
        selloCFD: sello,
        FechaTimbrado: fecha,
        noCertificadoSAT: certificado,
        version: version,
        selloSAT: timbre.attr('selloSAT')
      }
    end
    
    factura.impuestos << {impuesto: 'IVA'}
    
    factura
    
  end
  
end
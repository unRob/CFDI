# encoding: utf-8
require_relative '../lib/cfdi.rb'

describe CFDI::Comprobante do

  it "debe de poder instanciar sin datos" do
    comprobante = CFDI::Comprobante.new
    defaults = {
      :version=>"3.2",
      :fecha=>nil,
      :tipoDeComprobante=>"ingreso",
      :formaDePago=>nil,
      :condicionesDePago=>nil,
      :subTotal=>0,
      :TipoCambio=>1,
      :moneda=>"pesos",
      :total=>0.0,
      :metodoDePago=>nil,
      :lugarExpedicion=>nil,
      :NumCtaPago=>nil,
      :emisor=>nil,
      :receptor=>nil,
      :conceptos=>[],
      :serie=>nil,
      :folio=>nil,
      :sello=>nil,
      :noCertificado=>nil,
      :certificado=>nil,
      :complemento=>nil,
      :cancelada=>nil,
      :impuestos=>[]
    }
    expect(comprobante.to_h).to be_eql(defaults)
  end

  it "debe de poder settear defaults" do
    CFDI::Comprobante.configure({defaults: {version: '2.0'}})
    comprobante = CFDI::Comprobante.new
    expect(comprobante.version).to eq '2.0'
  end

  it "debe de generar un comprobante desde XML" do
    comprobante = CFDI.from_xml(File.read('./examples/data/cfdi.xml'))
    returns = {
      :version=>"3.2",
      :fecha=>"2013-10-15T01:33:32",
      :tipoDeComprobante=>"ingreso",
      :formaDePago=>"PAGO EN UNA SOLA EXHIBICION",
      :condicionesDePago=>"Sera marcada como pagada en cuanto el receptor haya cubierto el pago.",
      :subTotal=>11000.0, :TipoCambio=>1, :moneda=>"pesos", :total=>12760.0, :metodoDePago=>"Transferencia Bancaria",
      :lugarExpedicion=>"Nutopia, Nutopia", :NumCtaPago=>nil,
      :emisor=>{:rfc=>"XAXX010101000",
        :nombre=>"Me cago en sus estándares S.A. de C.V.",
        :domicilioFiscal=>{
          :calle=>"Calle Feliz",
          :noExterior=>"42", :noInterior=>"314", :colonia=>"Centro",
          :localidad=>"No se que sea esto, pero va", :referencia=>"Sin Referencia", :municipio=>"Nutopía", :estado=>"Nutopía",
          :pais=>"Nutopía", :codigoPostal=>"31415"
        },
        :expedidoEn=>{
          :calle=>"Calle Feliz", :noExterior=>"42",
          :noInterior=>nil, :colonia=>"Centro", :localidad=>"No se que sea esto, pero va",
          :referencia=>"Sin Referencia", :municipio=>"Nutopía", :estado=>"Nutopía",
          :pais=>"Nutopía", :codigoPostal=>"31415"
        }, :regimenFiscal=>"Pruebas Fiscales"
      },
      :receptor=>{
        :rfc=>"XAXX010101000", :nombre=>"El SAT apesta S. de R.L.",
        :domicilioFiscal=>{
          :calle=>nil, :noExterior=>nil, :noInterior=>nil, :colonia=>nil, :localidad=>nil, :referencia=>"Sin Referencia",
          :municipio=>nil, :estado=>"Nutopía", :pais=>"Nutopía", :codigoPostal=>nil
        },
        :expedidoEn=>nil, :regimenFiscal=>nil
      },
      :conceptos=>[
        {:cantidad=>2, :unidad=>"Kilos", :noIdentificacion=>"KDV", :descripcion=>"Verga Ción", :valorUnitario=>5500.0, :importe=>11000.0}
      ],
      :serie=>nil, :folio=>"1",
      :sello=>"igFu7Q9Z98n6xFSLMv7a2y8ZlJCO+pgTX3xDAUt5xSpX3dHOKXkTHBAf4P/oHHDm3xkYkaNBfPEzpVFDrRVjL2rvkR5T9rsFqb4cl6DOo4RrRIpSR9vojLp7mFWiON9H6OFPi2b9PVAnyIx1Skb5iGIAmSQIhVYyt2DSauObY2c=",
      :noCertificado=>"20001000000200000293",
      :certificado=>"cadena-muy-muy-grande",
      :complemento=>nil, :cancelada=>nil, :impuestos=>[{:impuesto=>"IVA"}]
    }
    expect(comprobante.to_h).to eq returns
  end

  it "no debe de generar atributos vacios" do
    comprobante = CFDI.from_xml(File.read('./examples/data/cfdi.xml'))
    #el comprobante de XML no tiene numero de cuenta de pago
    expect(comprobante.to_xml).not_to match(/NumCtaPago/)

    #si quitamos referencia
    comprobante.emisor.domicilioFiscal.referencia = nil
    expect(comprobante.to_xml).not_to match(/DomicilioFiscal.+referencia/)
  end

  it "debe validar un Timbre Fiscal Digital" do
    comprobante = CFDI.from_xml(File.read('./examples/data/timbrado.xml'))
    cert = File.read('./examples/data/certPAC.cer')
    expect(comprobante.timbre_valido? cert).to be false
  end

end

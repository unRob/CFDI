# encoding: utf-8
require_relative '../lib/cfdi.rb'

require_relative './fixtures/cfdi_32'
require_relative './fixtures/cfdi_33'
require_relative './fixtures/cfdi_impuestos'
PARSED_32 = CFDI.from_xml(File.read('./examples/data/cfdi_32.xml'))

describe CFDI::Comprobante do

  it "debe de poder instanciar sin datos" do
    comprobante = CFDI::Comprobante.new
    expect(comprobante.to_h).to eq(CFDI_33)
  end

  it "debe de poder settear defaults" do
    CFDI::Comprobante.configure({defaults: {version: '2.0'}})
    comprobante = CFDI::Comprobante.new
    expect(comprobante.version).to eq '2.0'
  end

  it "debe de generar un comprobante desde XML" do
    expect(PARSED_32.to_h).to eq CFDI_32
  end

  it "debe de generar un comprobante desde XML incluyendo datos de impuestos" do
    comprobante = CFDI.from_xml(File.read('./examples/data/cfdi_impuestos.xml'))
    expect(comprobante.to_h).to eq CFDI_IMPUESTOS
  end

  it "no debe de generar atributos vacios" do
    #el comprobante de XML no tiene numero de cuenta de pago
    expect(PARSED_32.to_xml).not_to match(/NumCtaPago/)

    #si quitamos referencia
    PARSED_32.emisor.domicilioFiscal.referencia = nil
    expect(PARSED_32.to_xml).not_to match(/DomicilioFiscal.+referencia/)
  end

  it "debe validar un Timbre Fiscal Digital" do
    comprobante = CFDI.from_xml(File.read('./examples/data/timbrado.xml'))
    cert = File.read('./examples/data/certPAC.cer')
    expect(comprobante.timbre_valido? cert).to be false
  end

end

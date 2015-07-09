module CFDI

  # Un concepto del comprobante
  class Addenda

    attr_accessor *[:nombre, :prefix, :namespace, :xsd, :data]

    def initialize data={}
      #puts self.class
      data.each do |k,v|
        method = "#{k}=".to_sym
        next if !self.respond_to? method
        self.send method, v
      end
    end

    def ns
      {
        "xmlns:#{prefix}" => namespace,
        "xsi:schemaLocation" => "#{namespace} #{xsd}"
      }.merge(props)
    end

    def props
      data.reject {|k, v| v.is_a?(Array) || v.is_a?(Hash) }
    end

    def each &block
      @data.each do |name, content|
        next if props.keys.include?(name)
        yield name, content
      end
    end

  end #Addenda


  # module XSD

  #   class Element

  #     def initialize name, type, minOcurrs:0, maxOcurrs: 1
  #       @name = name
  #     end

  #   end

  #   class Addenda
  #     include Enumerable

  #     attr_reader :namespace, :schema, :prefix

  #     def initialize namespace, prefix: 'cfdi'
  #       @schema = []
  #       @namespace = namespace
  #       @prefix = prefix.downcase
  #     end

  #     def prefix= str
  #       @prefix = str.downcase
  #     end

  #     def each &block
  #       return Enumerable.new(@schema) unless block_given?
  #       @schema.each(&block)
  #     end

  #     def to_xsd
  #       ns = {
  #         targetNamespace: namespace,
  #         elementFormDefault: 'qualified',
  #         attributeFormDefault: 'unqualified',
  #         xmlns: "http://www.w3.org/2001/XMLSchema",
  #         'xmlns:xs' => "http://www.w3.org/2001/XMLSchema",
  #         "xmlns:#{prefix}" => namespace
  #       }
  #       @builder = Nokogiri::XML::Builder.new do |xml|
  #         xml.schema(ns) {

  #         }
  #       end

  #       @builder.to_xml
  #     end

  #   end

  # end



end #CFDI
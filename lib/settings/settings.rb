class Settings
  class Error < RuntimeError; end

  include Log::Dependency

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def self.logger
    @logger ||= Log.get(self)
  end

  def self.build(source=nil)
    source ||= implementer_source

    data_source = DataSource::Build.(source)

    data = data_source.get_data

    data = Casing::Underscore.(data)

    # assure symbols here

    instance = new(data)

    instance
  end

  def self.implementer_source
    logger.trace { "Getting data source from the implementer" }

    unless self.respond_to? :data_source
      logger.trace { "Implementer doesn't provide a data_source" }
      return nil
    end

    self.data_source.tap do |data_source|
      logger.trace { "Got data source from the implementer (#{data_source})" }
    end
  end

  def set(receiver, *namespace, attribute: nil, strict: true)
    logger.trace { "Setting #{receiver.class.name} (#{digest(namespace, attribute, strict)})" }
    unless attribute.nil?
      value = set_attribute(receiver, attribute, namespace, strict)
    else
      receiver = set_object(receiver, namespace, strict)
    end
    value || receiver
  end

  def set_attribute(receiver, attribute, namespace, strict)
    logger.trace { "Setting #{receiver.class.name} attribute (#{digest(namespace, attribute, strict)})" }

    attribute = attribute.to_s if attribute.is_a?(Symbol)

    attribute_namespace = namespace.dup
    attribute_namespace << attribute

    value = get(attribute_namespace)

    if value.nil?
      msg = "#{attribute_namespace} not found in the data"
      logger.error { msg }
      raise Settings::Error, msg
    end

    Settings::Setting::Assignment::Attribute.assign(receiver, attribute.to_sym, value, strict)

    logger.debug { "Set #{receiver.class.name} #{attribute} to #{value.inspect}" }

    value
  end

  def set_object(receiver, namespace, strict)
    logger.trace { "Setting #{receiver.class.name} object (#{digest(namespace, nil, strict)})" }

    data = get(namespace)

    if data.nil?
      msg = "#{namespace} not found in the data"
      logger.error { msg }
      raise Settings::Error, msg
    end

    data.each do |attribute, value|
      Settings::Setting::Assignment::Object.assign(receiver, attribute.to_sym, value, strict)
    end

    logger.debug { "Set #{receiver.class.name} object (#{digest(namespace, nil, strict)})" }

    receiver
  end

  def assign_value(receiver, attribute, value, strict=false)
    Settings::Setting::Assignment.assign(receiver, attribute, value, strict)
  end

  def get(*namespace)
    namespace.flatten!
    logger.trace { "Getting #{namespace}" }

    string_keys = namespace.map { |n| n.is_a?(String) ? n : n.to_s }

    value = if string_keys.empty?
              data
            else
              data.dig(*string_keys)
            end

    logger.debug { "Got #{namespace}" }
    logger.debug(tag: :data) { "#{namespace}: #{value.inspect}" }

    value
  end

  def digest(namespace, attribute, strict)
    content = []
    content << "Namespace: #{namespace.join ', '}" unless namespace.empty?
    content << "Attribute: #{attribute}" if attribute
    strict = "<not set>" if strict.nil?
    content << "Strict: #{strict}"
    content.join ', '
  end
end

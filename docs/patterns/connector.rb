class Connector
  def self.instance
    @@instance ||= new
  end

  def dup
    type_error(__method__)
  end

  def clone
    type_error(__method__)
  end

  private

  def type_error(method_name)
    raise "TypeError: can't #{method_name} instance of singleton Connector"
  end

  private_class_method :new
end

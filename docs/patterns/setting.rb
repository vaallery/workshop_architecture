class Setting
  include Singleton
  # extend Forwardable
  # def_delegators :@list, :[]=, :[]

  def initialize
    @list = {}
  end

  def []=(key, value)
    @list[key] = value
  end

  def [](key)
    @list[key]
  end
end

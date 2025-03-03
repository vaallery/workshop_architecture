class Setting
  include Singleton
  extend Forwardable
  def_delegators :@list, :[]=, :[]

  def initialize
    @list = {}
  end
end

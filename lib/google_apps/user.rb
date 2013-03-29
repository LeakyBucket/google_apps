module GoogleApps
  class User
    attr_accessor :login, :given_name, :family_name, :storage_quota, :hashed_password, :suspended
    alias_method :last_name, :family_name
    alias_method :first_name, :given_name
    alias_method :suspended?, :suspended

    def initialize(attrs = {})
      self.attributes = attrs
    end

    private
    def attributes=(attrs)
      attrs && attrs.each_pair { |name, value| self.send("#{name}=", value) }
    end
  end
end
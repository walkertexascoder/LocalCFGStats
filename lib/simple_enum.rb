module SimpleEnum

  extend ActiveSupport::Concern

  included do

    def initialize(name, id)
      @name = name
      @id = id
    end

    attr_reader :name, :id

    extend Enumerable

    def self.all_collection
      @all ||= []
    end

  end

  module ClassMethods

    def enum(*args)
      instance = new(*args)
      remember(instance)
      instance
    end

    def remember(instance)
      all_collection << instance
    end

    def each
      all_collection.each {|x| yield x }
    end

    def for_id(id)
      find {|x| x.id == id }
    end

    def all
      all_collection
    end

  end

end
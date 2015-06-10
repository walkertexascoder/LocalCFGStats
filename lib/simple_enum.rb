module SimpleEnum

  extend ActiveSupport::Concern

  included do

    def initialize(name, id)
      @name = name
      @id = id
    end

    attr_reader :name, :id

    extend Enumerable

  end

  module ClassMethods

    def enum(*args)
      instance = new(*args)
      remember(instance)
      instance
    end

    def remember(instance)
      @@all ||= []
      @@all << instance
    end

    def each
      @@all.each {|x| yield x }
    end

    def all
      @@all
    end

  end

end
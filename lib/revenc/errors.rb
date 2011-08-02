module Revenc

  class Errors
    include Enumerable

     def initialize
       @errors ={}
     end

     # add errors, error_on can be a symbol or object instance
     def add(error_on, message = "Unknown error")

       # humanize error_on
       if error_on.is_a?(Symbol)
         error_on_str = error_on.to_s
       else
         error_on_str = underscore(error_on.class.name)
       end
       error_on_str = error_on_str.gsub(/\//, '_')
       error_on_str = error_on_str.gsub(/_/, ' ')
       error_on_str = error_on_str.gsub(/^revenc/, '').strip
       #error_on_str = error_on_str.capitalize

       @errors[error_on_str] ||= []
       @errors[error_on_str] << message.to_s
    end

    def empty?
      @errors.empty?
    end

    def clear
      @errors = {}
    end

    def each
      @errors.each_key { |attr| @errors[attr].each { |msg| yield attr, msg } }
    end

    def size
      @errors.values.inject(0) { |error_count, attribute| error_count + attribute.size }
    end

    alias_method :count, :size
    alias_method :length, :size

    def messages
      messages = []

      @errors.each_key do |attr|
      @errors[attr].each do |message|
        next unless message
        attr_name = attr.to_s
        messages << attr_name + ' ' + message
        end
      end

      messages
    end

    def to_sentences
      messages.join("\n")
    end

    private

    # from ActiveSupport
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

  end

end

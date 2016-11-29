module Contactually
  module Models
    module Model
      attr_reader :interface

      def self.included(base)
        base.send :extend, ClassMethods
      end

      def initialize(interface, params={})
        @interface = interface
        options = params.dup

        options.each do |attr, _value|
          self.send("#{attr}=", options.delete(attr)) if respond_to?(attr)
        end if options

        @_extra_attributes = options

        super()
      end

      def attributes
        self.class.field_list.inject({}) do |acc, field_name|
          value = send(field_name)

          if Array === value
            if value.first.respond_to?(:attributes)
              value = value.map(&:attributes)
            else
              value
            end
          end

          acc.merge(field_name.to_s => value)
        end
      end

      private

      attr_reader :_extra_attributes

      def type_cast(value, type)
        case type
          when :string then value.to_s
          when :integer then value.to_i
          when :float then value.to_f
          when :date then value.to_date
          when :boolean
            if !!value == value
              value
            else
              raise Contactually::TypeMismatchError.new(["Expected a boolean but got #{value.class}"])
            end
          when :datetime then DateTime.parse(value)
          else
            case type
              when Array
                value.map { |obj| type.first.new(obj) }
              else
                if type == Hash
                  value
                else
                  type.new(value)
                end
            end
        end
      end

      def method_missing(method, *args, **kwargs)
        string_method = method.to_s

        if _extra_attributes.has_key?(string_method)
          _extra_attributes[string_method]
        else
          super
        end
      end

      module ClassMethods
        attr_accessor :field_list

        def field(field_name, type)
          register_field field_name

          private_method = define_method "#{field_name}=" do |value|
            instance_variable_set "@#{field_name}", type_cast(value, type)
          end
          private private_method
        end

        def field_list
          @field_list ||= []
        end

        def register_field(field_name)
          class_eval do
            attr_reader field_name
          end

          self.field_list << field_name
        end
      end
    end
  end
end

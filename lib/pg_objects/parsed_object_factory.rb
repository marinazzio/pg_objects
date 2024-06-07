#
# Returns an object of the respective class based on the provided parsed query
#
class PgObjects::ParsedObjectFactory
  class << self
    include Dry::Monads[:try, :result]

    SUPPORTED_TYPES = %i[
      aggregate
      conversion
      event_trigger
      function
      materialized_view
      operator
      operator_class
      table
      text_search_parser
      text_search_template
      trigger
      type
      view
    ].freeze

    def create_object(input_data)
      @input_data = input_data
      @stmt = input_data.tree.stmts[0].stmt

      determine_class.new(stmt)
    end

    private

    attr_reader :stmt, :input_data

    def determine_class
      SUPPORTED_TYPES.each do |type|
        return class_for(type) if send("#{type}?")
      end
    end

    def class_for(type)
      "PgObjects::ParsedObject::#{type.to_s.classify}".constantize
    end

    def aggregate?
      try_check_get_result { stmt.define_stmt.kind == :OBJECT_AGGREGATE }
    end

    def conversion?
      try_check_get_result { stmt.create_conversion_stmt.conversion_name.present? }
    end

    def event_trigger?
      try_check_get_result { stmt.create_event_trig_stmt.trigname.present? }
    end

    def function?
      try_check_get_result { stmt.create_function_stmt.funcname.present? }
    end

    def materialized_view?
      try_check_get_result { stmt.create_table_as_stmt.objtype == :OBJECT_MATVIEW }
    end

    def operator_class?
      try_check_get_result { stmt.create_op_class_stmt.opclassname.present? }
    end

    def operator?
      try_check_get_result { stmt.define_stmt.kind == :OBJECT_OPERATOR }
    end

    def table?
      try_check_get_result { stmt.create_stmt.table_elts.present? }
    end

    def text_search_parser?
      try_check_get_result { stmt.define_stmt.kind == :OBJECT_TSPARSER }
    end

    def text_search_template?
      try_check_get_result { stmt.define_stmt.kind == :OBJECT_TSTEMPLATE }
    end

    def trigger?
      try_check_get_result { stmt.create_trig_stmt.trigname.present? }
    end

    def type?
      try_check_get_result { stmt.composite_type_stmt.typevar.present? }
    end

    def view?
      try_check_get_result { stmt.view_stmt.view.present? }
    end

    def try_check_get_result(&)
      result = Try(&).to_result

      result.success? && result.value!
    end
  end
end

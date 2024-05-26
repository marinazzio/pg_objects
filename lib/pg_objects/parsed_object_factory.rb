class PgObjects::ParsedObjectFactory
  class << self
    include Dry::Monads[:try, :result]

    def create_object(input_data)
      @input_data = input_data
      @stmt = input_data.tree.stmts[0].stmt

      parsed_object_class =
        case
        when aggregate? then class_for(:aggregate)
        when conversion? then class_for(:conversion)
        when event_trigger? then class_for(:event_trigger)
        when function? then class_for(:function)
        when materialized_view? then class_for(:materialized_view)
        when operator_class? then class_for(:operator_class)
        when operator? then class_for(:operator)
        when table? then class_for(:table)
        when text_search_parser? then class_for(:text_search_parser)
        when text_search_template? then class_for(:text_search_template)
        when trigger? then class_for(:trigger)
        when type? then class_for(:type)
        when view? then class_for(:view)
        end

      parsed_object_class.new(input_data)
    end

    private

    attr_reader :stmt, :input_data

    def class_for(type)
      # type = kind.to_s.downcase.split('_').slice(1..).join('_').classify
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

    def try_check_get_result
      result = Try { yield }.to_result

      result.success? && result.value!
    end
  end
end

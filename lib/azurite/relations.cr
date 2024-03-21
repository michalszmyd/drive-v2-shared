module Azurite
  module Relations
    macro has_many(name, foreign_key)
      def joins_{{name}}
        joins("INNER JOIN {{name.id}} ON {{name.id}}.{{foreign_key.id}} = #{table_name}.id")
      end

      def left_joins_{{name}}
        joins("LEFT JOIN {{name.id}} ON {{name.id}}.{{foreign_key.id}} = #{table_name}.id")
      end
    end

    macro belongs_to(name, foreign_key)
      {{join_table_name = "#{name.id}s"}}

      def joins_{{name}}
        joins("INNER JOIN #{{{join_table_name}}} ON #{{{join_table_name}}}.id = #{table_name}.{{foreign_key.id}}")
      end

      def left_joins_{{name}}
        joins("LEFT JOIN #{{{join_table_name}}} ON #{{{join_table_name}}}.id = #{table_name}.{{foreign_key.id}}")
      end
    end
  end
end

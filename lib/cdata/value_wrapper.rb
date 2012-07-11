# encoding: utf-8

#  Copyright (C) 2012  Jan Bujak <j+cdata@jabster.pl>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#  As a special exception, you may create a larger work that contains part or
#  all of the C/C++ code generated by CData and distribute that work under
#  terms of your choice. If you modify this library, you may extend this
#  exception to your version of the library, but you are not obliged to do so.
#  If you do not wish to do so, delete this exception statement from your
#  version.

module CData

    class ValueWrapper

        attr_accessor :value, :name, :type, :is_exported, :children

        def initialize( value, name, type, is_exported, is_referenced )

            @value             = value
            @name              = name
            @type              = type
            @is_exported       = is_exported
            @is_referenced     = is_referenced
            @children          = []

        end

        def generic_name

            return "generic__#{name}"

        end

        def is_referenced

            return @is_exported || @is_referenced

        end

        def array_children

            if type.instance_of?( ArrayType )
                return @children
            elsif type.instance_of?( ClassType ) && type.is_arraylike == true
                count = @type.cached_methods.size
                return @children[ 0...( @children.size - count ) ]
            else
                return []
            end

        end

        def hash_children

            if type.instance_of?( HashType )
                return @children
            elsif type.instance_of?( ClassType ) && type.is_hashlike == true
                count = @type.cached_methods.size
                return @children[ 0...( @children.size - count ) ]
            else
                return []
            end

        end

        def class_children

            return [] unless type.instance_of?( ClassType )
            if type.is_arraylike == true || type.is_hashlike == true || type.is_stringlike == true

                count = @type.cached_methods.size
                return [] if count == 0
                return @children[ (count * -1)..-1 ]

            end

            return @children

        end

        def string_child

            return nil unless type.instance_of?( ClassType ) && type.is_stringlike == true
            return @children[ 0 ]

        end

        def reference( expected_type = nil )

            if expected_type == GenericType::instance

                return "&#{generic_name}"

            end

            if @value == nil

                if expected_type == BoolType::instance

                    return "false"

                elsif expected_type == FloatType::instance

                    return "0.0f"

                else

                    return "0"

                end

            end

            if @type == FloatType::instance

                return "#{@value.to_f}f"

            elsif @type.instance_of?( IntType )

                return @value.to_i.to_s

            elsif @value == true

                return 'true'

            elsif @value == false

                return 'false'

            elsif @type == StringType::instance

                return name

            elsif @type.instance_of?( ClassType ) && @type != expected_type

                return "(#{expected_type.reference_name})&#{name}"

            else

                return "&#{name}"

            end

        end

    end

end
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

    VERSION = 1

end

require 'stringio'
require 'cdata/set.rb'

require 'cdata/util.rb'
require 'cdata/hashes.rb'
require 'cdata/types.rb'
require 'cdata/value_wrapper.rb'

require 'cdata/input.rb'
require 'cdata/output.rb'
require 'cdata/code.rb'
require 'cdata/private.rb'

module CData

    class Serializer

        # The header file contents after generation.
        attr_reader :header

        # The source file contents after generation.
        attr_reader :source

        # An array of lines that gets inserted into the header prologue.
        # Empty by default.
        attr_accessor :header_prologue

        # An array of lines that gets inserted inte the source prologue.
        # Empty by default.
        attr_accessor :source_prologue

        def initialize

            @header = nil
            @source = nil

            @header_prologue = [ ]
            @source_prologue = [ ]

            @float_type   = FloatType.instance
            @string_type  = StringType.instance
            @bool_type    = BoolType.instance
            @generic_type = GenericType.instance
            @nil_type     = NilType.instance

            INT_TYPES.each do |type|

                id = type.gsub( ' ', '_' ) + "_instance"

                int_type = IntType.send( id )
                instance_variable_set( "@#{type.gsub( " ", "_" )}_type", int_type )

            end

            @int_value_to_value_wrapper = {}
            @float_value_to_value_wrapper = {}
            @bool_value_to_value_wrapper = {}
            @string_value_to_value_wrapper = {}
            @array_value_to_value_wrapper = {}
            @hash_value_to_value_wrapper = {}
            @class_value_to_value_wrapper = {}
            @stringlike_class_value_to_value_wrapper_map = {}
            @nil_value_wrapper = nil

            @value_wrappers = []
            @klass_to_klass_type = {}
            @last_id = 0

            @types_for_qualified_path = {}
            @wrappers_for_qualified_path = {}

        end

    end

end
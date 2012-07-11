#!/usr/bin/ruby
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

require 'cdata'

class Structure

    attr_accessor :a, :b, :c, :d, :e, :f, :g, :h

    def initialize( a = nil, b = nil, c = nil, d = nil, e = nil, f = nil, g = nil, h = nil )
        @a, @b, @c, @d, @e, @f, @g, @h = a, b, c, d, e, f, g, h
    end

    def self.cdata_methods
        [ :a, :b, :c, :d, :e, :f, :g, :h ]
    end

    def cdata_hash
        return self.__id__
    end

end

class AnotherStructure

    attr_accessor :a

    def initialize( a = nil )
        @a = a
    end

    def self.cdata_methods
        [ :a ]
    end

end

class Base

    attr_accessor :a

    def initialize( a = nil )
        @a = a
    end

    def self.cdata_methods
        [ :a ]
    end

end

class Child < Base

    attr_accessor :b1

    def initialize( a = nil, b = nil )
        @a = a
        @b1 = b
    end

    def self.cdata_methods
        [ :b1 ]
    end

end

class AnotherChild < Base

    attr_accessor :b2

    def initialize( a = nil, b = nil )
        @a = a
        @b2 = b
    end

    def self.cdata_methods
        [ :b2 ]
    end

end

class PureChild < Base

    def initialize( a = nil )
        @a = a
    end

end

class Valuelike

    attr_accessor :a

    def initialize( a )
        @a = a
    end

    def hash
        return @a.hash
    end

    def eql?( another )
        return false unless another.instance_of?( Valuelike )
        return @a == another.a
    end

    def self.cdata_methods
        return [ :a ]
    end

end

class Stringlike < String

    attr_accessor :a

    def initialize( a, value )

        @a = a
        self.replace( value )

    end

    def self.cdata_methods
        return [ :a ]
    end

end

class AnotherStringlike < String

    def initialize( value )

        self.replace( value )

    end

end

class Arraylike < Array

    attr_accessor :a

    def initialize( a, elements )

        @a = a
        elements.each { |element| self << element }

    end

    def self.cdata_methods
        return [ :a ]
    end

end

class Hashlike < Hash

    attr_accessor :a

    def initialize( a, elements )

        @a = a
        elements.each { |key, value| self[ key ] = value }

    end

    def self.cdata_methods
        return [ :a ]
    end

end

def test( variables = [] )

    serializer = CData::Serializer.new
    variables.each do |variable|
        serializer.serialize variable
    end
    yield( serializer ) if block_given?

    serializer.generate
    header = serializer.header
    source = serializer.source

    filename = "/tmp/libcdata-testcase-#{Process.pid}"

    File.open( "#{filename}.cc", "wb" ) do |fp|
        fp.puts header
        fp.puts source
        fp.puts "int main() { return 0; }"
    end

    system "g++ #{filename}.cc -o /dev/null -Wall -Wextra -Werror -O0"
    if $?.exitstatus != 0

        puts "error: compilation failed! (#{Kernel.caller[0]})"

        exit 1

    end

    File.unlink( "#{filename}.cc" )
    print '.'

    return header + "\n" + source

end

def test_hash( value )

    serializer = CData::Serializer.new
    serializer.serialize value, "g_value"

    serializer.generate
    header = serializer.header
    source = serializer.source

    filename = "/tmp/libcdata-testcase-#{Process.pid}"

    File.open( "#{filename}.cc", "wb" ) do |fp|
        fp.puts header
        fp.puts source
        fp.puts "#include <stdio.h>"
        fp.puts 'int main() { printf( "%u", cdata_hash( g_value ) ); }'
    end

    system "g++ #{filename}.cc -o #{filename} -Wall -Wextra -Werror -O0"
    if $?.exitstatus != 0

        puts "error: compilation failed! (#{Kernel.caller[0]})"

        exit 1

    end

    print '.'

    native_hash = `#{filename}`.to_i
    ruby_hash   = value.cdata_hash

    File.unlink( "#{filename}.cc" )
    File.unlink( "#{filename}" )

    if native_hash != ruby_hash

        puts "error: hash mismatch (native:#{native_hash} != ruby:#{ruby_hash}) for #{value.inspect}"
        exit 1

    end

end

def test_code( value, code )

    serializer = CData::Serializer.new
    serializer.serialize value, "g_value"
    if block_given?
        yield serializer
    end

    serializer.generate
    header = serializer.header
    source = serializer.source

    filename = "/tmp/libcdata-testcase-#{Process.pid}"

    File.open( "#{filename}.cc", "wb" ) do |fp|
        fp.puts header
        fp.puts source
        fp.puts "#include <stdio.h>"
        fp.puts "int main() { #{code}; return 0; }"
    end

    system "g++ #{filename}.cc -o #{filename} -Wall -Wextra -Werror -O0"
    if $?.exitstatus != 0

        puts "error: compilation failed! (#{Kernel.caller[0]})"

        exit 1

    end

    `#{filename}`
    if $?.exitstatus != 0

        puts "error: code failed! (#{Kernel.caller[0]})"
        File.unlink( "#{filename}" )

        exit 1

    end

    File.unlink( "#{filename}.cc" )
    File.unlink( "#{filename}" )
    print '.'

end

def test_should_not_compile( value, code = '' )

    serializer = CData::Serializer.new
    serializer.serialize value, "g_value"

    serializer.generate
    header = serializer.header
    source = serializer.source

    filename = "/tmp/libcdata-testcase-#{Process.pid}"

    File.open( "#{filename}.cc", "wb" ) do |fp|
        fp.puts header
        fp.puts source
        fp.puts "#include <stdio.h>"
        fp.puts "int main() { #{code}; return 0; }"
    end

    `g++ #{filename}.cc -o /dev/null -Wall -Wextra -Werror -O0 2>&1`
    if $?.exitstatus == 0

        puts "error: compilation didn't fail! (#{Kernel.caller[0]})"
        exit 1

    end
    print '.'

end

puts "cdata: running testsuite..."

test [ 1 ]
test [ "1" ]
test [ 1.0 ]
test [ true ]
test [ false ]
test [ [ true, false ] ]
test [ [] ]
test [ {} ]
test [ nil ]
test [ Structure.new() ]
test [ Structure.new(1) ]
test [ Structure.new("1") ]
test [ Structure.new(1.0) ]
test [ Structure.new(true) ]
test [ Structure.new(false) ]
test [ Structure.new(true), Structure.new(false) ]
test [ Structure.new([]), Structure.new([1]) ]
test [ Structure.new([[]]), Structure.new([[1]]) ]
test [ Structure.new({}) ]
test [ Structure.new(1), Structure.new(nil) ]
test [ Structure.new("1"), Structure.new(nil) ]
test [ Structure.new(1.0), Structure.new(nil) ]
test [ Structure.new(true), Structure.new(nil) ]
test [ Structure.new(false), Structure.new(nil) ]
test [ Structure.new([]), Structure.new(nil) ]
test [ Structure.new({}), Structure.new(nil) ]
test [ [ Child.new(), AnotherChild.new() ] ]
test [ Child.new( 1, 2 ), Child.new( 3, 4 ) ]
test [ Structure.new( Child.new ), Structure.new( AnotherChild.new ) ]
test [ [ Structure.new, AnotherStructure.new ] ]
test [ Structure.new( Structure.new ), Structure.new( AnotherStructure.new ) ]
test [ PureChild.new( 1 ) ]
test [ { 1 => "1" } ]
test [ { "1" => 1 } ]
test [ { 1.0 => "1.0" } ]
test [ { true => true } ]
test [ { false => false } ]
test [ { 1 => Structure.new() } ]
test [ { 1 => nil } ]
test [ { nil => nil } ]
test [ { 1 => Structure.new(), 2 => nil } ]
test [ Structure.new( [], [] ), Structure.new( [ "" ], [ true ] ) ]
test [ Structure.new( 1 ), Structure.new( 2 ** 16 + 1 ), AnotherStructure.new( 1 ) ]

test [ [ [ 1 ], [] ] ]
test [ { 1 => [ 1 ], 2 => [] } ]
test [ { 3 => { Structure.new => [ AnotherStructure.new ], Structure.new => [] } } ]

test [ { -1 => -1 } ]
test [ { 2 **  8 - 1 => 2 **  8 - 1 } ]
test [ { 2 ** 16 - 1 => 2 ** 16 - 1 } ]
test [ { 2 ** 32 - 1 => 2 ** 32 - 1 } ]

test [ Structure.new( 1, Structure.new( 2 ) ) ]
test [ Structure.new( 1, true, 1.0, "1", [], {} ), Structure.new() ]

test [ [ 1, true, 1.0, "1", [], {}, Structure.new ] ]

test do |s|

    s.serialize( true, 't1' )
    s.serialize( true, 't2' )

end

test do |s|

    a = Structure.new
    b = Structure.new
    a.a = b
    b.a = a

    s.serialize( a )
    s.serialize( b )

end

test_hash( 0 )
test_hash( 1 )
test_hash( 2 ** 8 - 1 )
test_hash( 2 ** 16 - 1 )
test_hash( 2 ** 32 - 1 )
test_hash( 2 ** 32 )
test_hash( 2 ** 32 + 1 )
test_hash( -1 )
test_hash( -2 )
test_hash( (2 ** 8 - 1) * -1 )
test_hash( (2 ** 16 - 1) * -1 )
test_hash( (2 ** 32 - 1) * -1 )
test_hash( true )
test_hash( false )
test_hash( "Hello World!" )
test_hash( nil )

test_code( true, 'return !(g_value == true)' )
test_code( [], 'return !(g_value.size == 0 && g_value.data != 0)' )
test_code( [ 1, 2, 3 ], 'return !(g_value.size == 3 && g_value.data[ 0 ] == 1 && g_value.data[ 1 ] == 2 && g_value.data[ 2 ] == 3)' )
test_code( {}, 'return !(g_value.first_bucket_index == (unsigned)~0)' )
test_code( {}, 'return !(g_value[ 0 ] == 0)' )
test_code( {}, 'return !(g_value.has_key( 0 ) == false)' )
test_code( {}, 'cdata_nil_t key; cdata_nil_t value; cdata_hash_index_t index; return !(g_value.first( key, value, index ) == false)' )
test_code( {}, 'cdata_nil_t value; cdata_hash_index_t index; return !(g_value.first( value, index ) == false)' )
test_code( {}, 'cdata_nil_t key; cdata_nil_t value; cdata_hash_index_t index; return !(g_value.next( key, value, index ) == false)' )
test_code( {}, 'cdata_nil_t value; cdata_hash_index_t index; return !(g_value.next( value, index ) == false)' )
test_code( { 1 => "1", 2 => "2" }, 'return !(g_value.has_key( 0 ) == false && g_value.has_key( 1 ) == true && g_value.has_key( 2 ) == true)' )
test_code( { 1 => "1", 2 => "2" }, 'return !(g_value[ 0 ] == 0 && !strcmp( g_value[ 1 ], "1" ) && !strcmp( g_value[ 2 ], "2" ) )' )
test_code( { 1 => "1", 2 => "2" }, 'unsigned char key; const char * value; cdata_hash_index_t index; return !(g_value.first( key, value, index ) == true)' )
test_code( { 1 => "1", 2 => "2" }, 'unsigned char key; const char * value; cdata_hash_index_t index; g_value.first( key, value, index ); return !(key == 1 && !strcmp( value, "1" ))' )
test_code( { 1 => "1", 2 => "2" }, 'unsigned char key; const char * value; cdata_hash_index_t index; g_value.first( key, value, index ); return !(g_value.next( key, value, index ) == true)' )
test_code( { 1 => "1", 2 => "2" }, 'unsigned char key; const char * value; cdata_hash_index_t index; g_value.first( key, value, index ); g_value.next( key, value, index ); return !(key == 2 && !strcmp( value, "2" ))' )
test_code( { 1 => "1" }, 'unsigned char key; const char * value; cdata_hash_index_t index; g_value.first( key, value, index ); return !(g_value.next( key, value, index ) == false)' )
test_code( { 1 => nil }, 'unsigned char key; cdata_nil_t value; cdata_hash_index_t index; return !(g_value.first( key, value, index ) == true)' )
test_code( { 1 => nil }, 'unsigned char key; cdata_nil_t value; cdata_hash_index_t index; g_value.first( key, value, index ); return !(key == 1 && value == 0)' )
test_code( { 1 => Structure.new(), 2 => nil }, 'unsigned char key; const structure_t * value; cdata_hash_index_t index; g_value.first( key, value, index ); g_value.next( key, value, index ); return !(key == 2 && value == 0)' )
test_code( Child.new( 1, 2 ), 'const base_t * value = g_value; return !(value->a == 1 && g_value->b1 == 2)' )
test_code( Structure.new( 1, [ Structure.new( 256 ) ] ), 'return !(sizeof(g_value.a) > 1)' )

test_code( [ Structure.new( Child.new ), Structure.new( AnotherChild.new ) ], 'const base_t * value = g_value[ 0 ]->a; return !(value != 0)' )
test_should_not_compile( [ Structure.new( Child.new ), Structure.new( AnotherChild.new ) ], 'const child_t * value = g_value[ 0 ]->a; return !(value != 0)' )
test_should_not_compile( [ Structure.new( Child.new ), Structure.new( AnotherChild.new ) ], 'const another_child_t * value = g_value[ 1 ]->a; return !(value != 0)' )

test_code( [ Child.new(), AnotherChild.new() ], 'const base_t * value = g_value[ 0 ]; return !(value != 0)' )
test_should_not_compile( [ Child.new(), AnotherChild.new() ], 'const child_t * value = g_value[ 0 ]; return !(value != 0)' )
test_should_not_compile( [ Child.new(), AnotherChild.new() ], 'const another_child_t * value = g_value[ 1 ]; return !(value != 0)' )

test_code( [ 1, true, 1.0, "1", [], {}, Structure.new ],
        "
            if( g_value.size != 7 ) return 1;
            if( g_value[ 0 ]->type != cdata_type_unsigned_char ) return 1;
            if( g_value[ 1 ]->type != cdata_type_bool ) return 1;
            if( g_value[ 2 ]->type != cdata_type_float ) return 1;
            if( g_value[ 3 ]->type != cdata_type_string ) return 1;
            if( g_value[ 4 ]->type != cdata_type_nil_array ) return 1;
            if( g_value[ 5 ]->type != cdata_type_nil_to_nil_hash ) return 1;
            if( g_value[ 6 ]->type != cdata_type_structure ) return 1;
        " )

test_code( [ nil, false ],
        "
            if( g_value.size != 2 ) return 1;
            if( g_value[ 0 ] != false ) return 1;
            if( g_value[ 1 ] != false ) return 1;
        " )

test_code( { 1 => nil, 2 => false }, "if( g_value.size != 2 ) return 1;" )
test_code( [ 1, 2, 3 ], "unsigned char sum = 0; for( unsigned_char_array_t :: iterator i = g_value.begin(); i != g_value.end(); ++i ) sum += *i; return !(sum == 6)" )

test_code( [ Base.new( 1 ), Base.new( 1 ) ], 'return !(g_value.data[ 0 ] != g_value.data[ 1 ])' )
test_code( [ Valuelike.new( 1 ), Valuelike.new( 1 ) ], 'return !(g_value.data[ 0 ] == g_value.data[ 1 ])' )

test [ Arraylike.new( 1, [ 2, 3 ] ) ]
test_code( [ Arraylike.new( 1, [ 2, 3 ] ) ],
        "const arraylike_t * value = g_value[ 0 ];
         if( value->data[ 0 ] != 2 ) return 1;
         if( value->data[ 1 ] != 3 ) return 1;
         if( value->a != 1 ) return 1;
         " )

test [ Hashlike.new( 1, { 2 => 3 } ) ]
test [ Stringlike.new( 1, "2" ) ]
test [ Stringlike.new( 1, "X" ), AnotherStringlike.new( "X" ) ]
test_code( [ Stringlike.new( 1, "X" ), AnotherStringlike.new( "X" ) ], "if( g_value[ 0 ] == g_value[ 1 ] ) return 1;" )

# Those strings should be merged.
test_should_not_compile( [ "1", "1" ], 'return !(s00000000 == s00000001)' )

puts
puts 'cdata: all ok!'

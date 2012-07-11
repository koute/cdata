What is cdata?
--------------

CData lets you serialize arbitrary Ruby structures into static C++ data.

Try running this:

    require 'cdata'

    s = CData::Serializer.new
    s.serialize [ 1, 2, 3 ], 'g_array'

    s.source_prologue << '#include "data.h"'
    s.generate

    File.open( "data.h", "wb" ) { |fp| fp.puts s.header }
    File.open( "data.cpp", "wb" ) { |fp| fp.puts s.source }


Then compile this:

    #include <stdio.h>
    #include "data.h"

    int main()
    {
        for( auto value: g_array )
            printf( "%i\n", value );
        return 0;
    }

Output:

    $ g++ data.cpp main.cpp -std=c++0x
    $ ./a.out
    1
    2
    3

Supported features
-----------------

* All basic Ruby types (Integers, Arrays, Hashes, Strings, etc.)
* Custom user defined types. (Just define self.cdata_methods() that returns
  a list of symbols you want serialized.)
* Space efficient - variable types are picked according to the content.
  For example - if you only have integers less than 256 in an array then
  they will be serialized as unsigned chars.)
* Cyclic dependencies between objects.

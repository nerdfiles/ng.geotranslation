[![Stories in Ready](https://badge.waffle.io/nerdfiles/ng.geotranslation.png?label=ready&title=Ready)](https://waffle.io/nerdfiles/ng.geotranslation)
#ng.geotranslation

A client-side service presenting various methods for the calculation of 
geospatial metadata between points and sanitization of input/outputs.

##Use-cases

1. You don't need "duration" properties that Google's distance calculator offers.
2. Your backend calculates distance with limitations.
3. Interest in unloading server time with calculations distributed across clients,  
   and cached on clients. (The client should always cache appropriately.)

##Install

    $ bower install ng.geotranslation

## Development

    $ grunt compile
    $ python -c 'import SimpleHTTPServer; SimpleHTTPServer.test()'
    $ open ./example/page1.html

##Usage

    angular.module('YrApp', ['ngGeotranslation'])
    .controller([
        '$$geotranslate',
        function ($$geotranslate) {
            // @note L/l should be floats.
            // Initial and final bearing (which may differ).
            var bearing1 = $$geotranslate.bearingFrom(L1, l1, L2, l2);
            var bearing2 = $$geotranslate.bearingTo(L1, l1, L2, l2);

            // Get direction.
            var direction = $$geotranslate.direction(L1, l1, L2, l2);

            // Get distance.
            var distance1 = $$geotranslate.equirectangular(L1, l1, L2, l2); // @needs fix
            var distance2 = $$geotranslate.spherical(L1, l1, L2, l2); // @needs fix
            var distance3 = $$geotranslate.haversine(L1, l1, L2, l2);
        }
    ]);

##Dependencies

See ``bower.json``.

##Review

1. http://www.yourhomenow.com/house/haversine.html  
   Expand input types.

##License

[WTFPL](http://www.wtfpl.net/txt/copying/)

[![Stories in Ready](https://badge.waffle.io/nerdfiles/ng.geotranslation.png?label=ready&title=Ready)](https://waffle.io/nerdfiles/ng.geotranslation)
#ng.geotranslation

A client-side service presenting various methods for the calculation of 
distances between ``latLngStart`` and ``latLngEnd``.

##Use-cases

1. You don't need "duration" properties that Google's distance calculator offers.
2. Your backend calculates distance with limitations.
3. Interest in unloading server time with calculations distributed across clients,  
   and cached on clients. (The client should always cache appropriately.)

##Get

    $ bower install ng.geotranslation

##Install

- ``<script>`` include?
- AMD?

##Usage

    angular.module('YrApp', ['ngGeotranslation'])
    .controller([
        '$$geotranslate',
        function ($$geotranslate) {
            // Initial and final bearing (which may differ).
            var bearing1 = $$geotranslate.bearingFrom(L1, l1, L2, l2);
            var bearing2 = $$geotranslate.bearingTo(L1, l1, L2, l2);

            // Get direction.
            var direction = $$geotranslate.direction(L1, l1, L2, l2);

            // Get distance.
            var distance1 = $$geotranslate.equirectangular(L1, l1, L2, l2);
            var distance2 = $$geotranslate.spherical(L1, l1, L2, l2);
            var distance3 = $$geotranslate.haversine(L1, l1, L2, l2);
        }
    ]);

##Dependencies

- [bower-angular](https://github.com/angular/bower-angular)

See ``bower.json``.

##Review

1. http://www.yourhomenow.com/house/haversine.html (@TODO)

##License

[WTFPL](http://www.wtfpl.net/txt/copying/)

# ng.geotranslation

A client-side service presenting various methods for the calculation of 
distances between ``latLngStart`` and ``latLngEnd``.

## Get

    $ bower install ng.geotranslation

## Install

- ``<script>`` include?
- AMD?

## Usage

    angular.module('YrApp', ['ngGeotranslation'])
    .controller([
        '$$geotranslate',
        function ($$geotranslate) {
            // Some json data with lat/lng.
            var bearing1 = $$geotranslate.bearingFrom(L1, l1, L2, l2);
            var bearing2 = $$geotranslate.bearingTo(L1, l1, L2, l2);
            var distance1 = $$geotranslate.equirectangular(L1, l1, L2, l2);
            var distance2 = $$geotranslate.spherical(L1, l1, L2, l2);
            var distance3 = $$geotranslate.haversine(L1, l1, L2, l2);
        }
    ]);

## Dependencies

- [bower-angular](https://github.com/angular/bower-angular)

See ``bower.json``.

## License

[WTFPL](http://www.wtfpl.net/txt/copying/)

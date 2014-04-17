/**
 * @license ng.geotranslation.js
 * License: WTFPL
 */
(function (window, angular, undefined) {
    'use strict';

    /**
     * @ngdoc overview
     * @name ngGeotranslation
     * @description
     *
     * # ngGeotranslation
     */
    angular.module('ngGeotranslation', ['ng'])
    /**
     * @ngdoc service
     * Mean radius of Earth as constant service (in km).
     */
    .constant('ngGeotranslation.RADIUS', 6371)
    /**
     * @ngdoc service
     * Cached elementary translation calculation.
     *
     * @test For performance gains.
     */
    .constant('ngGeotranslation.cachedDeg2Rad', Math.PI / 180)
    /**
     * @ngdoc service
     * Cached elementary translation calculation.
     *
     * @test For performance gains.
     */
    .constant('ngGeotranslation.cachedRad2Deg', 180 / Math.PI)
    /**
     * @ngdoc service
     * @name ngGeotranslation.$$geotranslate
     * @description
     *
     * The `$$geotranslate` allows developers to calculate distance using haversine method.
     */
    .service('$$geotranslate', [
        'ngGeotranslation.RADIUS',
        'ngGeotranslation.cachedDeg2Rad',
        'ngGeotranslation.cachedRad2Deg',
        function (RADIUS, cachedDeg2Rad, cachedRad2Deg) {
            var serviceInterface = {};
            /**
             * @util
             *
             * toRad
             *
             * Convert to radians.
             */
            serviceInterface.toRad = function (angle) {
                return angle * cachedDeg2Rad;
            };
            /**
             * @util
             *
             * toDeg
             *
             * Convert to degrees.
             */
            serviceInterface.toDeg = function (angle) {
                return angle * cachedRad2Deg;
            };
            /**
             * @util
             *
             * bearingTo
             *
             * Compute the initial bearing when going from a point to another.
             *
             * @param {float} latitudeStart
             * @param {float} longitudeStart
             * @param {float} latitudeEnd
             * @param {float} longitudeEnd
             * @return {number} Initial bearing.
             * @unit °
             */
            serviceInterface.bearingTo = function (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
                var distanceLongitude = this.toRad(longitudeEnd - longitudeStart),
                    x, y, initialBearing;
                latitudeStart = this.toRad(latitudeStart);
                latitudeEnd = this.toRad(latitudeEnd);
                y = Math.sin(distanceLongitude) * Math.cos(latitudeEnd);
                x = Math.cos(latitudeStart) * Math.sin(latitudeEnd) -
                    Math.sin(latitudeStart) * Math.cos(latitudeEnd) * Math.cos(distanceLongitude);
                initialBearing = this.toDeg(Math.atan2(y, x));
                if (initialBearing < 0) {
                    initialBearing += 360;
                }
                return initialBearing;
            };
            /**
             * @util
             *
             * bearingFrom
             *
             * Compute the final bearing when going from a point to another.
             *
             * @param {float} latitudeStart
             * @param {float} longitudeStart
             * @param {float} latitudeEnd
             * @param {float} longitudeEnd
             * @return {number} Final bearing.
             * @unitSymbol °
             */
            serviceInterface.bearingFrom = function (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
                var finalBearing = this.bearingTo(
                        latitudeStart, longitudeStart,
                        latitudeEnd, longitudeEnd
                    );
                finalBearing += 180;
                if (finalBearing > 360) {
                    finalBearing -= 360;
                }
                return finalBearing;
            };
            /**
             * spherical
             *
             * @param {float} latitudeStart
             * @param {float} longitudeStart
             * @param {float} latitudeEnd
             * @param {float} longitudeEnd
             * @return {number} Distance
             * @unitSymbol km
             */
            serviceInterface.spherical = function (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
                var
                    l1 = this.toRad(latitudeStart),
                    l2 = this.toRad(latitudeEnd),
                    l3 = this.toRad((longitudeEnd - longitudeStart)),
                    distance = Math.acos(
                        Math.sin(l1) * Math.sin(l2) +
                        Math.cos(l1) * Math.cos(l2) * Math.cos(l3)
                    ) * RADIUS;
                return distance;
            };
            /**
             * equirectangular
             *
             * Equirectangular Projection.
             *
             * @see http://www.movable-type.co.uk/scripts/latlong.html
             *
             * @param {float} latitudeStart
             * @param {float} longitudeStart
             * @param {float} latitudeEnd
             * @param {float} longitudeEnd
             * @return {number} Distance
             * @unitSymbol km
             */
            serviceInterface.equirectangular = function (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
                var
                    x = (longitudeEnd - longitudeStart) * Math.cos((latitudeStart + latitudeEnd) / 2),
                    y = (latitudeEnd - latitudeStart),
                    distance = Math.sqrt(x * x + y * y) * RADIUS;
                return distance;
            };
            /**
             * haversine
             *
             * Compute the distance between two points using the haversine formula.
             *
             * @perf http://jsperf.com/haversine-salvador/8
             * @see http://www.movable-type.co.uk/scripts/latlong.html
             *
             * @param {float} latitudeStart
             * @param {float} longitudeStart
             * @param {float} latitudeEnd
             * @param {float} longitudeEnd
             * @return {number} Distance.
             * @unitSymbol km
             */
            serviceInterface.haversine = function (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
                var
                    distanceLatitude = this.toRad(latitudeEnd - latitudeStart),
                    distanceLongitude = this.toRad(longitudeEnd - longitudeStart),
                    a, c, distance;
                latitudeStart = this.toRad(latitudeStart);
                latitudeEnd = this.toRad(latitudeEnd);
                a = Math.sin(distanceLatitude / 2) * Math.sin(distanceLatitude / 2) +
                    Math.sin(distanceLongitude / 2) * Math.cos(latitudeStart) * Math.cos(latitudeEnd);
                c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                distance = RADIUS * c;
                return distance;
            };
            /**
             * Return utilities of service.
             */
            return serviceInterface;
        }
    ]);
})(window, window.angular);


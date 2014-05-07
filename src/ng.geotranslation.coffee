# @license ng.geotranslation.js
# License: WTFPL
((window, angular) ->
    'use strict'

    # @ngdoc overview
    # @name ngGeotranslation
    # @description
    #
    # # ngGeotranslation
    angular.module('ngGeotranslation', ['ng'])

    # @ngdoc service
    # Mean radius of Earth as constant service (in km).
    .constant('ngGeotranslation.RADIUS', 6371)

    # @ngdoc service
    # Cached elementary translation calculation.
    #
    # @test For performance gains.
    .constant('ngGeotranslation.cachedDeg2Rad', Math.PI / 180)

    # @ngdoc service
    # Cached elementary translation calculation.
    #
    # @test For performance gains.
    .constant('ngGeotranslation.cachedRad2Deg', 180 / Math.PI)

    # @ngdoc service
    # @name ngGeotranslation.$$geotranslate
    # @description
    #
    # The `$$geotranslate` allows developers to calculate distance between two
    # points on Earth.
    .service '$$geotranslate', [
        'ngGeotranslation.RADIUS'
        'ngGeotranslation.cachedDeg2Rad'
        'ngGeotranslation.cachedRad2Deg'
        (RADIUS, cachedDeg2Rad, cachedRad2Deg) ->

            # Declare service interface.
            serviceInterface = {}

            # @util
            #
            # toRad
            #
            # Convert to radians.
            serviceInterface.toRad = (angle) ->
                angle * cachedDeg2Rad

            # @util
            #
            # toDeg
            #
            # Convert to degrees.
            serviceInterface.toDeg = (angle) ->
                angle * cachedRad2Deg

            # @util
            #
            # bearingTo
            #
            # Compute the initial bearing when going from a point to another.
            #
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {number} Initial bearing.
            # @unit °
            serviceInterface.bearingTo = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                distanceLongitude = @toRad(longitudeEnd - longitudeStart)
                latitudeStart = @toRad latitudeStart
                latitudeEnd = @toRad latitudeEnd
                y = Math.sin(distanceLongitude) * Math.cos(latitudeEnd)
                x = Math.cos(latitudeStart) * Math.sin(latitudeEnd) -
                    Math.sin(latitudeStart) * Math.cos(latitudeEnd) * Math.cos(distanceLongitude)
                initialBearing = @toDeg Math.atan2(y, x)
                if initialBearing < 0
                    initialBearing += 360
                initialBearing

            # @util
            #
            # bearingFrom
            #
            # Compute the final bearing when going from a point to another.
            #
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {number} Final bearing.
            # @unitSymbol °
            serviceInterface.bearingFrom = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                finalBearing = @bearingTo(
                    latitudeStart, longitudeStart,
                    latitudeEnd, longitudeEnd)
                finalBearing += 180
                if finalBearing > 360
                    finalBearing -= 360
                finalBearing

            # spherical
            #
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {number} Distance
            # @unitSymbol km
            serviceInterface.spherical = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                l1 = @toRad(latitudeStart)
                l2 = @toRad(latitudeEnd)
                l3 = @toRad((longitudeEnd - longitudeStart))
                distance = Math.acos(
                    Math.sin(l1) * Math.sin(l2) +
                    Math.cos(l1) * Math.cos(l2) * Math.cos(l3)
                ) * RADIUS

            # equirectangular
            #
            # Equirectangular Projection.
            #
            # @see http://www.movable-type.co.uk/scripts/latlong.html
            #
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {number} Distance
            # @unitSymbol km
            serviceInterface.equirectangular = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                x = (longitudeEnd - longitudeStart) * Math.cos((latitudeStart + latitudeEnd) / 2)
                y = (latitudeEnd - latitudeStart)
                distance = Math.sqrt(x * x + y * y) * RADIUS

            # haversine
            #
            # Compute the distance between two points using the haversine formula.
            #
            # @perf http://jsperf.com/haversine-salvador/8
            # @see http://www.movable-type.co.uk/scripts/latlong.html
            #
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {number} Distance.
            # @unitSymbol km
            serviceInterface.haversine = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                latitudeStart = @toRad latitudeStart
                latitudeEnd = @toRad latitudeEnd
                longitudeStart = @toRad longitudeStart
                longitudeEnd = @toRad longitudeEnd
                distanceLatitude = @toRad(latitudeEnd - latitudeStart)
                distanceLongitude = @toRad(longitudeEnd - longitudeStart)
                a = Math.sin(distanceLongitude / 2) * Math.sin(distanceLongitude / 2) +
                    Math.cos(latitudeStart) * Math.cos(latitudeEnd / 2) *
                    Math.sin(distanceLongitude / 2) * Math.sin(distanceLongitude / 2)
                c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
                distance = RADIUS * c

            # Return utilities of service.
            serviceInterface
        ]
)(window, window.angular)

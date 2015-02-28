# @license ng.geotranslation.js
# License: WTFPL
((window, angular) ->

    # @ngdoc overview
    # @name ngGeotranslation
    # @description
    #
    # # ngGeotranslation
    angular.module 'ngGeotranslation', ['ng']

    # @ngdoc service
    # Mean radius of Earth as constant service (in km).
    .constant 'ngGeotranslation.radius', 6371

    # @ngdoc service
    # Cached elementary translation calculation.
    #
    # @test For performance gains.
    .constant 'ngGeotranslation.cachedDeg2Rad', (Math.PI / 180)

    # @ngdoc service
    # Cached elementary translation calculation.
    #
    # @test For performance gains.
    .constant 'ngGeotranslation.cachedRad2Deg', (180 / Math.PI)

    .factory('$$position', (latitude, longitude) ->
        serviceInterface = @
        new $$position(latitude, longitude)  if not (@ instanceof $$position)
        @latitude = Number latitude
        @longitude = Number longitude
    )

    # @ngdoc service
    # @namespace $$geotranslate
    # @description
    #   The `$$geotranslate` allows developers to calculate distance between two
    #   points on Earth.
    # @see http://www.movable-type.co.uk/scripts/latlong.html
    .service('$$geotranslate', [
        'ngGeotranslation.radius'
        'ngGeotranslation.cachedDeg2Rad'
        'ngGeotranslation.cachedRad2Deg'
        (radius, cachedDeg2Rad, cachedRad2Deg) ->

            # Declare service interface.
            serviceInterface = @


            # @namespace toRad
            # @description
            #   Convert to radians.
            # @param {float} angle
            # @return {float}
            serviceInterface.toRad = (angle) ->
                angle * cachedDeg2Rad


            # @namespace toDeg
            #   Convert to degrees.
            # @param {float} angle
            # @return {float}
            serviceInterface.toDeg = (angle) ->
                angle * cachedRad2Deg


            # @namespace bearingTo
            # @description
            #   Compute the initial bearing when going from a point to another.
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {float} Initial bearing.
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


            # @namespace bearingFrom
            # @description
            #   Compute the final bearing when going from a point to another.
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {float} Final bearing.
            serviceInterface.bearingFrom = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                finalBearing = @bearingTo( latitudeStart, longitudeStart, latitudeEnd, longitudeEnd )
                finalBearing += 180
                if finalBearing > 360
                    finalBearing -= 360
                finalBearing


            # @namespace midpointTo
            # @description
            #   Returns the midpoint between 'this' point and the supplied point.
            # @param   {$$position} point - Latitude/longitude of destination point.
            # @returns {$$position} Midpoint between this point and the supplied point.
            # @example
            #   p1 = new $$position(52.205, 0.119)
            #   p2 = new $$position(48.857, 2.351)
            #   pMid = p1.midpointTo(p2) # pMid.toString(): 50.5363°N, 001.2746°E
            serviceInterface.midpointTo = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                L1 = @toRad latitudeStart
                l1 = @toRad longitudeStart
                L2 = @toRad latitudeEnd
                d1 = @toRad(longitudeEnd - longitudeStart)

                _x = Math.cos(l2) * Math.cos(d1)
                _y = Math.cos(l2) * Math.sin(d1)

                L3 = Math.atan2(
                    Math.sin(L1) + Math.sin(L2),
                    Math.sqrt( (Math.cos(L1) + _x) * (Math.cos(L1) + _x) + _y * _y )
                )

                l3 = l1 + Math.atan2(_y, Math.cos(L1) + _x)
                # normalise to -180..+180°
                l3 = (l3 + 3 * Math.PI) % (2 * Math.PI) - Math.PI

                {
                    latitude: @toDeg(L3)
                    longitude: @toDeg(l3)
                }


            # @namespace crossTrackDistanceTo
            # @description
            #   Returns (signed) distance from ‘this’ point to great 
            #   circle defined by start-point and end-point.
            # @param   {$$position} pathStart - Start point of great circle path.
            # @param   {$$position} pathBrngEnd - End point of great circle path.
            # @param   {number} [radius=6371e3] - (Mean) radius of earth (defaults to radius in metres).
            # @returns {number} Distance to great circle (-ve if to left, +ve if to right of path).
            # @example
            #   pCurrent = new $$position(53.2611, -0.7972)
            #   p1 = new $$position(53.3206, -1.7297)
            #   p2 = new $$position(53.1887, 0.1334)
            #   d = pCurrent.crossTrackDistanceTo(p1, p2)  # Number(d.toPrecision(4)): -307.5
            serviceInterface.crossTrackDistanceTo = (pathStart, pathEnd) ->
                _13 = pathStart.distanceTo(@, radius) / radius
                __13 = @toRad pathStart.bearingTo @
                __12 = @toRad pathStart.bearingTo(pathEnd)
                dxt = Math.asin( Math.sin(_13) * Math.sin(__13 - __12) ) * radius


            # @namespace spherical
            # @description
            #   Compute using Spherical Law of Cosines gives well-conditioned 
            #   results down to distances as small as a few metres on the 
            #   earth's surface.
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {float} Distance in kilometers (km).
            serviceInterface.spherical = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                l1 = @toRad latitudeStart
                l2 = @toRad latitudeEnd
                l3 = @toRad(longitudeEnd - longitudeStart)
                distance = Math.acos(
                    Math.sin(l1) * Math.sin(l2) +
                    Math.cos(l1) * Math.cos(l2) * Math.cos(l3)
                ) * radius


            # @namespace equirectangular
            # @description
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {float} Distance in kilometers (km).
            serviceInterface.equirectangular = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                x = @toRad(longitudeEnd - longitudeStart) * Math.cos((latitudeStart + latitudeEnd) / 2)
                y = (latitudeEnd - latitudeStart)
                distance = Math.sqrt(x * x + y * y) * radius


            # @namespace haversine
            # @description
            #   Compute using the great-circle distance between two points.
            #
            #   The earth is very slightly ellipsoidal; using a spherical 
            #   model gives errors typically up to 0.3% – see notes for 
            #   further details
            # @perf http://jsperf.com/haversine-salvador/8
            # @param {float} latitudeStart
            # @param {float} longitudeStart
            # @param {float} latitudeEnd
            # @param {float} longitudeEnd
            # @return {float} Distance. Distance in kilometers (km).
            serviceInterface.haversine = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->
                latitudeStartRad = @toRad latitudeStart
                latitudeEndRad = @toRad latitudeEnd
                distanceLatitude = @toRad(latitudeEnd - latitudeStart)
                distanceLongitude = @toRad(longitudeEnd - longitudeStart)
                a = Math.sin(distanceLatitude / 2) * Math.sin(distanceLatitude / 2) +
                    Math.cos(latitudeStartRad) * Math.cos(latitudeEndRad) *
                    Math.sin(distanceLongitude / 2) * Math.sin(distanceLongitude / 2)
                c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
                distance = radius * c


            # Return utilities of service.
            serviceInterface
        ]
    )
)(window, window.angular)



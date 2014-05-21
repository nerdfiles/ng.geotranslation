# @license ng.geotranslation.js
# License: WTFPL
'use strict'

# @ngdoc overview
# @name ngGeotranslation
# @description
#
# Provide latitudes and longitudes of starting points and destination 
# points as floats to get direction, distance, bearing.
#
# # ngGeotranslation
angular.module('ngGeotranslation', [])

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
  $$geotranslate
]

# Implement service.
$$geotranslate = (RADIUS, cachedDeg2Rad, cachedRad2Deg) ->

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

    distanceLongitude = serviceInterface.toRad longitudeEnd - longitudeStart
    latitudeStart = serviceInterface.toRad latitudeStart
    latitudeEnd = serviceInterface.toRad latitudeEnd

    y = Math.sin(distanceLongitude) * Math.cos(latitudeEnd)
    x = Math.cos(latitudeStart) * Math.sin(latitudeEnd) -
      Math.sin(latitudeStart) * Math.cos(latitudeEnd) * Math.cos(distanceLongitude)

    initialBearing = serviceInterface.toDeg Math.atan2(y, x)

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

    finalBearing = serviceInterface.bearingTo(
      latitudeStart, longitudeStart,
      latitudeEnd, longitudeEnd
    )

    finalBearing += 180

    if finalBearing > 360
      finalBearing -= 360

    finalBearing

  # direction
  #
  # @param {float} latitudeStart
  # @param {float} longitudeStart
  # @param {float} latitudeEnd
  # @param {float} longitudeEnd
  # @return {string} Angle.
  # @see http://www.mathsteacher.com.au/year7/ch08_angles/07_bear/bearing.htm
  serviceInterface.direction = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->

    bearing = serviceInterface.bearingFrom latitudeStart, longitudeStart, latitudeEnd, longitudeEnd
    # Converting -ve to +ve (0-360)
    bearing = ((bearing + 360) % 360).toFixed(1)

    if (bearing >= 0 and bearing < 90)
      return 'N' + (if not (bearing is 0) then bearing + 'E' else '')

    if (bearing >= 90 and bearing < 180)
      return (if not (bearing is 90) then ('S' + (180 - bearing).toFixed(1)) else '') + 'E'

    if bearing >= 180 and bearing < 270
      return 'S' + (if not (bearing is 180) then (bearing - 180).toFixed(1) + 'W' else '')

    if bearing >= 270
      return (if (bearing != 270) then 'N' + (360 - bearing).toFixed(1) else '') + 'W'

    'N'

  # spherical
  #
  # @param {float} latitudeStart
  # @param {float} longitudeStart
  # @param {float} latitudeEnd
  # @param {float} longitudeEnd
  # @return {number} Distance
  # @unitSymbol km
  serviceInterface.spherical = (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) ->

    l1 = serviceInterface.toRad latitudeStart
    l2 = serviceInterface.toRad latitudeEnd
    l3 = serviceInterface.toRad (longitudeEnd - longitudeStart)

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
    y = latitudeEnd - latitudeStart

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

    latitudeStart = serviceInterface.toRad latitudeStart
    latitudeEnd = serviceInterface.toRad latitudeEnd
    longitudeStart = serviceInterface.toRad longitudeStart
    longitudeEnd = serviceInterface.toRad longitudeEnd

    distanceLatitude = serviceInterface.toRad latitudeEnd - latitudeStart
    distanceLongitude = serviceInterface.toRad longitudeEnd - longitudeStart

    a = Math.sin(distanceLatitude / 2) * Math.sin(distanceLatitude / 2) +
      Math.cos(latitudeStart) * Math.cos(latitudeEnd / 2) *
      Math.sin(distanceLongitude / 2) * Math.sin(distanceLongitude / 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    distance = RADIUS * c

  # Return utilities of service.
  serviceInterface

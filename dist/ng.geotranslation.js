// Generated by CoffeeScript 1.7.1
(function() {
  (function(window, angular) {
    'use strict';
    var $$geotranslate;
    angular.module('ngGeotranslation', ['ng']).constant('ngGeotranslation.RADIUS', 6371).constant('ngGeotranslation.cachedDeg2Rad', Math.PI / 180).constant('ngGeotranslation.cachedRad2Deg', 180 / Math.PI).service('$$geotranslate', ['ngGeotranslation.RADIUS', 'ngGeotranslation.cachedDeg2Rad', 'ngGeotranslation.cachedRad2Deg', $$geotranslate]);
    return $$geotranslate = function(RADIUS, cachedDeg2Rad, cachedRad2Deg) {
      var serviceInterface;
      serviceInterface = {};
      serviceInterface.toRad = function(angle) {
        return angle * cachedDeg2Rad;
      };
      serviceInterface.toDeg = function(angle) {
        return angle * cachedRad2Deg;
      };
      serviceInterface.bearingTo = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
        var distanceLongitude, initialBearing, x, y;
        distanceLongitude = serviceInterface.toRad(longitudeEnd - longitudeStart);
        latitudeStart = serviceInterface.toRad(latitudeStart);
        latitudeEnd = serviceInterface.toRad(latitudeEnd);
        y = Math.sin(distanceLongitude) * Math.cos(latitudeEnd);
        x = Math.cos(latitudeStart) * Math.sin(latitudeEnd) - Math.sin(latitudeStart) * Math.cos(latitudeEnd) * Math.cos(distanceLongitude);
        initialBearing = serviceInterface.toDeg(Math.atan2(y, x));
        if (initialBearing < 0) {
          initialBearing += 360;
        }
        return initialBearing;
      };
      serviceInterface.bearingFrom = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
        var finalBearing;
        finalBearing = serviceInterface.bearingTo(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd);
        finalBearing += 180;
        if (finalBearing > 360) {
          finalBearing -= 360;
        }
        return finalBearing;
      };
      serviceInterface.direction = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
        var bearing;
        bearing = serviceInterface.bearingFrom(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd);
        bearing = ((bearing + 360) % 360).toFixed(1);
        if (bearing >= 0 && bearing < 90) {
          return 'N' + (!(bearing === 0) ? bearing + 'E' : '');
        }
        if (bearing >= 90 && bearing < 180) {
          return (!(bearing === 90) ? 'S' + (180 - bearing).toFixed(1) : '') + 'E';
        }
        if (bearing >= 180 && bearing < 270) {
          return 'S' + (!(bearing === 180) ? (bearing - 180).toFixed(1) + 'W' : '');
        }
        if (bearing >= 270) {
          return (bearing !== 270 ? 'N' + (360 - bearing).toFixed(1) : '') + 'W';
        }
        return 'N';
      };
      serviceInterface.spherical = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
        var distance, l1, l2, l3;
        l1 = serviceInterface.toRad(latitudeStart);
        l2 = serviceInterface.toRad(latitudeEnd);
        l3 = serviceInterface.toRad(longitudeEnd - longitudeStart);
        return distance = Math.acos(Math.sin(l1) * Math.sin(l2) + Math.cos(l1) * Math.cos(l2) * Math.cos(l3)) * RADIUS;
      };
      serviceInterface.equirectangular = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
        var distance, x, y;
        x = (longitudeEnd - longitudeStart) * Math.cos((latitudeStart + latitudeEnd) / 2);
        y = latitudeEnd - latitudeStart;
        return distance = Math.sqrt(x * x + y * y) * RADIUS;
      };
      serviceInterface.haversine = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
        var a, c, distance, distanceLatitude, distanceLongitude;
        latitudeStart = serviceInterface.toRad(latitudeStart);
        latitudeEnd = serviceInterface.toRad(latitudeEnd);
        longitudeStart = serviceInterface.toRad(longitudeStart);
        longitudeEnd = serviceInterface.toRad(longitudeEnd);
        distanceLatitude = serviceInterface.toRad(latitudeEnd - latitudeStart);
        distanceLongitude = serviceInterface.toRad(longitudeEnd - longitudeStart);
        a = Math.sin(distanceLatitude / 2) * Math.sin(distanceLatitude / 2) + Math.cos(latitudeStart) * Math.cos(latitudeEnd / 2) * Math.sin(distanceLongitude / 2) * Math.sin(distanceLongitude / 2);
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return distance = RADIUS * c;
      };
      return serviceInterface;
    };
  })(window, window.angular);

}).call(this);
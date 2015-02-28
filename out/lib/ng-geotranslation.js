(function() {
  (function(window, angular) {
    return angular.module('ngGeotranslation', ['ng']).constant('ngGeotranslation.radius', 6371).constant('ngGeotranslation.cachedDeg2Rad', Math.PI / 180).constant('ngGeotranslation.cachedRad2Deg', 180 / Math.PI).factory('$$position', function(latitude, longitude) {
      var serviceInterface;
      serviceInterface = this;
      if (!(this instanceof $$position)) {
        new $$position(latitude, longitude);
      }
      this.latitude = Number(latitude);
      return this.longitude = Number(longitude);
    }).service('$$geotranslate', [
      'ngGeotranslation.radius', 'ngGeotranslation.cachedDeg2Rad', 'ngGeotranslation.cachedRad2Deg', function(radius, cachedDeg2Rad, cachedRad2Deg) {
        var serviceInterface;
        serviceInterface = this;
        serviceInterface.toRad = function(angle) {
          return angle * cachedDeg2Rad;
        };
        serviceInterface.toDeg = function(angle) {
          return angle * cachedRad2Deg;
        };
        serviceInterface.bearingTo = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
          var distanceLongitude, initialBearing, x, y;
          distanceLongitude = this.toRad(longitudeEnd - longitudeStart);
          latitudeStart = this.toRad(latitudeStart);
          latitudeEnd = this.toRad(latitudeEnd);
          y = Math.sin(distanceLongitude) * Math.cos(latitudeEnd);
          x = Math.cos(latitudeStart) * Math.sin(latitudeEnd) - Math.sin(latitudeStart) * Math.cos(latitudeEnd) * Math.cos(distanceLongitude);
          initialBearing = this.toDeg(Math.atan2(y, x));
          if (initialBearing < 0) {
            initialBearing += 360;
          }
          return initialBearing;
        };
        serviceInterface.bearingFrom = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
          var finalBearing;
          finalBearing = this.bearingTo(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd);
          finalBearing += 180;
          if (finalBearing > 360) {
            finalBearing -= 360;
          }
          return finalBearing;
        };
        serviceInterface.midpointTo = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
          var L1, L2, L3, _x, _y, d1, l1, l3;
          L1 = this.toRad(latitudeStart);
          l1 = this.toRad(longitudeStart);
          L2 = this.toRad(latitudeEnd);
          d1 = this.toRad(longitudeEnd - longitudeStart);
          _x = Math.cos(l2) * Math.cos(d1);
          _y = Math.cos(l2) * Math.sin(d1);
          L3 = Math.atan2(Math.sin(L1) + Math.sin(L2), Math.sqrt((Math.cos(L1) + _x) * (Math.cos(L1) + _x) + _y * _y));
          l3 = l1 + Math.atan2(_y, Math.cos(L1) + _x);
          l3 = (l3 + 3 * Math.PI) % (2 * Math.PI) - Math.PI;
          return {
            latitude: this.toDeg(L3),
            longitude: this.toDeg(l3)
          };
        };
        serviceInterface.crossTrackDistanceTo = function(pathStart, pathEnd) {
          var _13, __12, __13, dxt;
          _13 = pathStart.distanceTo(this, radius) / radius;
          __13 = this.toRad(pathStart.bearingTo(this));
          __12 = this.toRad(pathStart.bearingTo(pathEnd));
          return dxt = Math.asin(Math.sin(_13) * Math.sin(__13 - __12)) * radius;
        };
        serviceInterface.spherical = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
          var distance, l1, l2, l3;
          l1 = this.toRad(latitudeStart);
          l2 = this.toRad(latitudeEnd);
          l3 = this.toRad(longitudeEnd - longitudeStart);
          return distance = Math.acos(Math.sin(l1) * Math.sin(l2) + Math.cos(l1) * Math.cos(l2) * Math.cos(l3)) * radius;
        };
        serviceInterface.equirectangular = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
          var distance, x, y;
          x = (longitudeEnd - longitudeStart) * Math.cos((latitudeStart + latitudeEnd) / 2);
          y = latitudeEnd - latitudeStart;
          return distance = Math.sqrt(x * x + y * y) * radius;
        };
        serviceInterface.haversine = function(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) {
          var a, c, distance, distanceLatitude, distanceLongitude, latitudeEndRad, latitudeStartRad;
          latitudeStartRad = this.toRad(latitudeStart);
          latitudeEndRad = this.toRad(latitudeEnd);
          distanceLatitude = this.toRad(latitudeEnd - latitudeStart);
          distanceLongitude = this.toRad(longitudeEnd - longitudeStart);
          a = Math.sin(distanceLatitude / 2) * Math.sin(distanceLatitude / 2) + Math.cos(latitudeStartRad) * Math.cos(latitudeEndRad) * Math.sin(distanceLongitude / 2) * Math.sin(distanceLongitude / 2);
          c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
          return distance = radius * c;
        };
        return serviceInterface;
      }
    ]);
  })(window, window.angular);

}).call(this);

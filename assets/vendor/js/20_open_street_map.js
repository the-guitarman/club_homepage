$(document).ready(function(){
  var map = $("#osm-map");
  if (map.length > 0) {

    var mapOperations = {
      markerPopupHTML: function(markerOptions) {
        var html = '<b>' + markerOptions.headline + '</b><br />';
        if (markerOptions.url) {
          html = html + '<a href="' + markerOptions.url + '" target="_blank" rel="nofollow">' + markerOptions.name + '</a><br />';
        } else {
          html = html + markerOptions.name + '<br />';
        }
        html = html + markerOptions.address;
        return html;
      },

      addMarkers: function(map, markers) {
        $.each(markers, function(index, markerOptions){
          mapOperations.createMarker(map, markerOptions);
        });
      },

      createMarker: function(map, markerOptions) {
        L.marker([markerOptions.lat, markerOptions.lng], {
          draggable: true,
          icon: markerOptions.icon
        })
        .addTo(map)
        .bindPopup(mapOperations.markerPopupHTML(markerOptions))
        .openPopup();
      },

      addRoutingControls: function(map, waypoints, markers) {
        L.Routing.control({
          waypoints: waypoints,
          /*
          fitSelectedRoute: true,
          lineOptions: L.Routing.Line({
            addWaypoints: false
          }),
          autoRoute: true,
          useZoomParameter: true
          */
          plan: L.Routing.plan(waypoints, {
            createMarker: function(i, wp) {
              return L.marker(wp.latLng, {
                draggable: true,
                icon: markers[i].icon
              })
              .bindPopup(mapOperations.markerPopupHTML(markers[i]))
              .openPopup();
            },
            geocoder: L.Control.Geocoder.nominatim(),
            routeWhileDragging: true
          }),
          routeWhileDragging: true,
          routeDragTimeout: 250,
          showAlternatives: true,
          altLineOptions: {
            styles: [
              {color: 'black', opacity: 0.15, weight: 9},
              {color: 'white', opacity: 0.8, weight: 6},
              {color: 'blue', opacity: 0.5, weight: 2}
            ]
          }
        })
        .on('routingerror', function() {
          try {
            map.getCenter();
          } catch (e) {
            map.fitBounds(L.latLngBounds(waypoints));
          }
        })
        .addTo(map);
      }
    };


    var myURL = window.location.origin + '/';

    var meetingPointIcon = L.icon({
      iconUrl: myURL + 'images/osm/meeting_point_24x24.png',
      iconRetinaUrl: myURL + 'images/osm/meeting_point_48x48.png',
      iconSize: [24, 24],
      iconAnchor: [12, 12],
      popupAnchor: [0, -14]
    });

    var matchGroundIcon = L.icon({
      iconUrl: myURL + 'images/osm/soccer_ball_24x24.png',
      iconRetinaUrl: myURL + 'images/osm/soccer_ball_48x48.png',
      iconSize: [24, 24],
      iconAnchor: [12, 12],
      popupAnchor: [0, -14]
    });

    var markers = [];

    var meetingPoint  = map.data('meeting-point');
    meetingPoint['icon'] = meetingPointIcon;
    markers.push(meetingPoint);

    var matchLocation = map.data('match-location');
    if (typeof(matchLocation) == "object") {
      matchLocation['icon'] = matchGroundIcon;
      markers.push(matchLocation);
    }

    var waypoints = [];
    $.each(markers, function(index, el){
      waypoints.push(L.latLng(el.lat, el.lng));
    });

    var mapOptions = {
      scrollWheelZoom: false
    };
    if (markers.length === 1) {
      mapOptions['center']  = waypoints[0];
      mapOptions['minZoom'] = 2;
      mapOptions['zoom']    = 17;
    }

    // mapOptions['layers'] = MQ.mapLayer();
    var map = L.map('osm-map', mapOptions);
    /*
     map.doubleClickZoom.disable();
     map.dragging.disable();
     map.touchZoom.disable();
     map.scrollWheelZoom.disable();
     map.boxZoom.disable();
     map.keyboard.disable();
     */

    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: ''
    }).addTo(map);

    if (markers.length > 1) {
      mapOperations.addRoutingControls(map, waypoints, markers);
    } else {
      mapOperations.addMarkers(map, markers);
    }
  }
});

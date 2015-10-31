function initFullScreenButtons(map) {
    var mapContainer = $("#map-container");
    var googleMapWidth = mapContainer.css('width');
    var googleMapHeight = mapContainer.css('height');

    $('#btn-enter-full-screen').click(function() {
        var center = map.getCenter();

        mapContainer.css({
            position: 'fixed',
            top: 0,
            left: 0,
            width: '100%',
            height: '100%',
            backgroundColor: 'white'
        });

        $("#track-map").css({
            height: '100%'
        });

        google.maps.event.trigger(map, 'resize');
        map.setCenter(center);

        $('#track-distance-elevation-plot').toggle();

        // Gui
        $('#btn-enter-full-screen').toggle();
        $('#btn-exit-full-screen').toggle();

        return false;
    });

    $('#btn-exit-full-screen').click(function() {
        var center = map.getCenter();

        mapContainer.css({
            position: 'relative',
            top: 0,
            width: googleMapWidth,
            height: googleMapHeight,
            backgroundColor: 'transparent'
        });

        google.maps.event.trigger(map, 'resize');
        map.setCenter(center);

        $('#track-distance-elevation-plot').toggle();

        // Gui
        $('#btn-enter-full-screen').toggle();
        $('#btn-exit-full-screen').toggle();
        return false;
    });

    $('.btn-full-screen').toggle();
}

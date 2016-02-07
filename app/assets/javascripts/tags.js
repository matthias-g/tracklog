
$(function() {
    $("#add-viewers-pane .close").click(function() {
        $("#add-viewers-pane").fadeOut("fast");
    });

    $("#add-viewers-link").click(function() {
        $("#add-viewers-pane").fadeIn("fast");
        return false;
    });
});

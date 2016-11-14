$(function() {
  var button = $("#test");
  button.click(function() {
    button
    .addClass('btn-warning')
    .removeClass('btn-success')
    .removeClass('btn-danger')
    .text('Verbindung testen');
    if (button.hasClass("save")) {
      button.text('Verbindung speichern …');
      $.ajax({
        method: "POST",
        url: "/init/datenbank/speichern",
        data: $("form").serialize()
      })
      .done(function(response) {
        if (response == "true") {
          button
          .addClass('btn-success')
          .addClass('restart')
          .removeClass('btn-warning')
          .removeClass('save')
          .text('Server mit neuen Einstellungen laden');
        }
        else {
          button
          .addClass('btn-danger')
          .removeClass('btn-success')
          .text('Speichern fehlgeschlagen');
        }
      });
    }
    else if (button.hasClass("restart")) {
      button
      .addClass('btn-warning')
      .removeClass('btn-success')
      .text('Server wird neu gestartet …');
      $.get("/restart")
      .done(function(){
        var loop=0;
        while (loop<1000) {
          $.ajax({
            url: "/ping",
            type: "GET",
            async: false})
            .done(function(data, textStatus, jqXHR) {
              if (jqXHR.status == 200) {
                loop = 1000;
                window.location.href = "/";
              }
            });
            loop++;
        }
      });
    }
    else {
      $.ajax({
        method: "POST",
        url: "/init/datenbank/test",
        data: $("form").serialize()
      })
      .done(function(response) {
        if (response == "true") {
          button
          .addClass('btn-success')
          .removeClass('btn-warning')
          .text('Verbindung speichern')
          .addClass('save');
        }
        else {
          button
          .addClass('btn-danger')
          .removeClass('btn-warning')
          .text('Verbindung fehlgeschlagen');
        }
      });
    }
  });
});


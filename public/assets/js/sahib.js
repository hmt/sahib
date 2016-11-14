$(function() {
  var status = function(s,j) {
    var color;
    var text = "✓";
    switch (s) {
      case 2:
        color = "success";
        break;
      case 8:
        color = "warning";
        break;
      case 9:
        color = "danger";
        text = j;
        break;
      default:
        color = "info";
    }
    return '<span class=\"label label-' + color + '\">' + text + '</span>';
  };
  var schueler = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 30,
    remote: '/suche/schueler/autocomplete.json?pattern=%QUERY'
  });
  var klassen = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 30,
    remote: '/suche/klassen/autocomplete.json?pattern=%QUERY'
  });
  schueler.initialize();
  klassen.initialize();

  $("#searchinput").typeahead(null, {
    name: 'name',
    displayKey: 'value',
    source: klassen.ttAdapter()
  },
    { name: 'name',
      displayKey: 'value',
      source: schueler.ttAdapter(),
      templates: {
        suggestion: function (data) {
          return '<p>' + data.value + ' ' + status(data.status, data.jahr) + '</p>';

        }
      }
    })
    .on("typeahead:selected typeahead:autocompleted", function(e, datum) {
      window.location.href = datum.link;
    });

  $(".frame-link").click(function(event) {
    event.preventDefault();
    $("#doc-frame")
      .attr({
        "src": $(this).attr("href"),
        "scrolling": "no",
        "frameborder": "0"
      })
      .on('load', function() {
        $(this).css("height", $(this).contents().height() + "px");
        $(this).css("width", $(this).contents().width() + "px");
        reload_warnungen();
      });
    $('a[href="#vorschau"]')
      .tab('show');
    $("#vorschau-tab").css("visibility", "visible");
    $('.pdf-button').css("display", "");
    $('#pdf-link').attr("href", this.dataset.pdflink);
  });
  $("#searchinput").focus();
  $(".clickable-row").click(function() {
    window.document.location = $(this).data("url");
  });
  $('[data-toggle="tooltip"]').tooltip();


  $(".toggle-warnungen").text(
    "Warnungen "+(localStorage.warnungen == "true" ? "ausschalten" : "einschalten")
  );

  $(".toggle-warnungen").click(function(event) {
    event.preventDefault();
    var link = $(this);
    var enable_warnungen = localStorage.warnungen;
    if (enable_warnungen == "true") {
      localStorage.warnungen = "false";
      link.text("Warnungen einschalten");
    }
    else {
      localStorage.warnungen = "true";
      link.text("Warnungen ausschalten");
    }
  });

  $("#update-repos").click(function() {
    var link = $(this);
    $.get('/repos/update/all')
      .done(function(response) {
        if (response == "true") {
          link.text('Aktualisiert');
          $.get('/restart');
        }
        else {
          link.text('Fehlgeschlagen');
        }
      });
  });

  var reload_warnungen = function() {
    $("#fehler-modal-body-name").empty();
    $.get('/warnungen/warnungen.json')
      .done(function(warnungen) {
        for (var schueler_warnungen in warnungen) {
          $("#fehler-modal-body-name").append("<dt>"+schueler_warnungen+"</dt>");
          var $iterator = warnungen[schueler_warnungen][Symbol.iterator]();
          var $result = $iterator.next();
          while (!$result.done) {
            var meldung = $result.value;
            $("#fehler-modal-body-name").append("<dd>"+meldung+"</dd>");
            $result = $iterator.next();
          }
        }
        if (Object.keys(warnungen).length > 0) {
          $('#label-warnungen').show();
        }
        else {
          $('#label-warnungen').hide();
        }
        if (Object.keys(warnungen).length > 0 && localStorage.warnungen) {
          show_warnungen();
        }
      });
  };

  var show_warnungen = function() {
    $('#fehler-modal').modal();
  };

  $("#label-warnungen").click(function(event) {
    event.preventDefault();
    show_warnungen();
  });
  $('img[data-failover]').error(function(){
    var failover = $(this).data('failover');
    if (this.src != failover){
      this.src = failover;
    }
  });

  if ($('.tab-content').length) {
    //Ersetze URL mit Tab-Adresse, damit man über back navigieren kann
    history.replaceState(null, null, "#schueler");
    $(window).scrollTop(0);

    //Tab navigation
    // add a hash to the URL when the user clicks on a tab
    $('a[data-toggle="tab"]').on('click', function(e) {
      history.pushState(null, null, $(this).attr('href'));
    });
    // navigate to a tab when the history changes
    window.addEventListener("popstate", function(e) {
      var activeTab = $('[href=' + location.hash + ']');
      if (activeTab.length) {
        activeTab.tab('show');
      } else {
        $('.nav-tabs a:first').tab('show');
      }
    });
  }
});

$(function() {
  document.documentElement.addEventListener('stamped', function(e){
    $('paper-progress').attr('disabled', true);
  }, true);
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
    var href = $(this).attr("href");
    event.preventDefault();
    $('paper-progress').attr('disabled', false);
    $("#doc-frame").remove();
    $("#vorschau-dom").append('<template id="doc-frame" is="juicy-html" content='+href+' on-stamped="stamped"></template>');
    $('a[href="#vorschau"]')
      .tab('show');
    $("#vorschau-tab").css("visibility", "visible");
    $('.pdf-button').css("display", "");
    $('#pdf-link').attr("href", this.dataset.pdflink);
    setTimeout(function(){reload_warnungen()}, 500);
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
      reload_warnungen();
    }
  });

  $("#update-repos").click(function() {
    var link = $(this);
    $.get('/repos/update/all')
      .done(function(response) {
        if (response == true) {
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
        if (Object.keys(warnungen).length > 0 && localStorage.warnungen == "true") {
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
  $('a[data-toggle="tab"]').historyTabs();
});

//sourced from https://github.com/jeffdavidgreen/bootstrap-html5-history-tabs
+function ($) {
    'use strict';
    $.fn.historyTabs = function() {
        var that = this;
        window.addEventListener('popstate', function(event) {
            if (event.state) {
                $(that).filter('[href="' + event.state.url + '"]').tab('show');
            }
        });
        return this.each(function(index, element) {
            $(element).on('show.bs.tab', function() {
                var stateObject = {'url' : $(this).attr('href')};

                if (window.location.hash && stateObject.url !== window.location.hash) {
                    window.history.pushState(stateObject, document.title, window.location.pathname + $(this).attr('href'));
                } else {
                    window.history.replaceState(stateObject, document.title, window.location.pathname + $(this).attr('href'));
                }
            });
            if (!window.location.hash && $(element).is('.active')) {
                // Shows the first element if there are no query parameters.
                $(element).tab('show');
            } else if ($(this).attr('href') === window.location.hash) {
                $(element).tab('show');
            }
        });
    };
}(jQuery);

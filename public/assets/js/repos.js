$(function() {
  $(".repo-list").on('click', '.toggle-repo', function(event) {
    _self = this;
    $.ajax({
      method: "PUT",
      url: "/repos/toggle-state",
      data: {"id":$(_self).data("id")}
    })
    .done(function(response) {
      $.get('/restart');
      $(_self).find("i")
        .toggleClass("fa-eye")
        .toggleClass("fa-eye-slash")
      $(_self)
        .parent()
          .toggleClass("bg-success");
      $(_self).parent().find(".update-repo > i").toggle();
    });
  });
  $(".repo-list").on('click', '.update-repo', function(event) {
    _self = this;
    $.ajax({
      method: "PUT",
      url: "/repos/update",
      data: {"id":$(_self).data("id")}
    })
    .done(function(response) {
      $.get('/restart');
      $(_self).parent()
        .toggleClass("bg-success");
    });
  });
  $(".repo-list").on('click', '.delete-repo', function(event) {
    _self = this;
    $.ajax({
      method: "DELETE",
      url: "/repos/delete",
      data: {"id":$(_self).data("id")}
    })
    .done(function(response) {
      $.get('/restart');
      $(_self).parent().remove()
    });
  });
  var button = $("#test");
  button.click(function() {
    var form = $("form");
    button
      .addClass('btn-warning')
      .removeClass('btn-success')
      .removeClass('btn-danger');
    button.text('Adresse speichern …');
    $.ajax({
      method: "POST",
      url: "/repos/create",
      data: $("form").serialize()
    })
    .done(function(response) {
      if (response == "true") {
        button
          .removeClass('btn-warning')
          .addClass('btn-success')
          .removeClass('save')
          .text('Gespeichert');
        $.get('/restart');
        $('.table > tbody').append("\
                                  <tr> \
                                  <td width='90%'>"+$('#inputName').val()+"</td> \
                                  <td class='update-repo' width='5%' data-id='"+$('#inputName').val()+"'><b class='clickable'>↻</b></td>\
                                  <td class='delete-repo' width='5%' data-id='"+$('#inputName').val()+"'><b class='clickable'>✕</b></td>"
                                 );
      }
      else {
        button
          .addClass('btn-danger')
          .removeClass('btn-success')
          .removeClass('btn-warning')
          .text('Fehler, wiederholen');
      }
    });
  });
});


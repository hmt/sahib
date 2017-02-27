$(function() {
  $(".repo-list").on('click', '.toggle-repo', function(event) {
    _self = this;
    $.ajax({
      method: "PUT",
      url: "/repos/toggle-state",
      dataType: "json",
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
      dataType: "json",
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
      dataType: "json",
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
      dataType: "json",
      url: "/repos/create",
      data: $("form").serialize()
    })
    .done(function(response) {
      if (response == true) {
        button
          .removeClass('btn-warning')
          .addClass('btn-success')
          .removeClass('save')
          .text('Gespeichert');
        $.get('/restart');
        $('.table > tbody').append("\
                    <tr>\
                      <td>"+$('#inputName').val()+"\
                      </td>\
                      <td>\
                      </td>\
                      <td class='update-repo trans' data-id='"+$('#inputName').val()+"' width='5%'>\
                        <i class='fa fa-refresh fa-lg clickable' style=''></i>\
                      </td>\
                      <td class='toggle-repo' data-id='"+$('#inputName').val()+"' width='5%'>\
                        <i class='fa fa-lg clickable fa-eye-slash'></i>\
                      </td>\
                      <td class='delete-repo' data-id='"+$('#inputName').val()+"' width='5%'>\
                        <i class='fa fa-trash fa-lg clickable'></i>\
                      </td>\
                    </tr>");
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


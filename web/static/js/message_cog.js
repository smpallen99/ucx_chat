import * as cc from "./chat_channel"

class MessageCog {
  constructor() {

  }
}

$(document).ready(function() {
  $('body').on('click','i.message-cog', function(e) {
    let id = $(this).closest('li.message').attr('id')
    console.log('message cog clicked...', id)
    cc.push('message_cog:open', {message_id: id})
      .receive("ok", resp => {
        $(this).parent().append(resp.html)
      })
  })
  $('body').on('click', '.message-dropdown-close', function(e) {
    close_cog($(this))
  })
  $('body').on('click', '.message-action', function(e) {
    let data_id = $(this).attr('data-id')
    let message_id = $(this).closest('li.message').attr('id')
    if (data_id == "edit-message") {
      cc.push('message:get-body:' + message_id)
        .receive("ok", resp => {
          $('textarea.input-message').text(resp.body).addClass('editing')
          $('#' + message_id).addClass('editing')
          close_cog($(this))
        })
    } else if (data_id == "delete-message") {
      sweetAlert({
        title: gettext.are_you_sure,
        text: gettext.you_will_not_be_able_to_recover_this_message,
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: gettext.yes_delete_it,
        closeOnConfirm: false
      },
      function(){
        cc.push("message_cog:" + data_id, {message_id: message_id})
          .receive("ok", resp => {
            swal({
                title: gettext.deleted,
                text: gettext.your_entry_has_been_deleted,
                type: 'success',
                timer: 1500,
                showConfirmButton: false,
            })
          })
          .receive("error", resp => {
            toastr.error(resp.error)
          })
      });

    } else {
      cc.push('message_cog:' + data_id, {message_id: message_id})
        .receive("ok", resp => {
          if (resp.selector &&  resp.html) {
            $(resp.selector).html(resp.html)
          }
          close_cog($(this))
        })
    }
  })
})

function close_cog(selector) {
  $(selector).closest('.message-dropdown').remove()
}

export default MessageCog

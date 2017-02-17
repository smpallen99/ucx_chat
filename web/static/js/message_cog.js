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
  $('body').on('click', '.message-action', function(e) {
    let data_id = $(this).attr('data-id')
    let message_id = $(this).closest('li.message').attr('id')
    cc.push('message_cog:' + data_id, {message_id: message_id})
      .receive("ok", resp => {
        if (resp.selector &&  resp.html) {
          $(resp.selector).html(resp.html)
        }
        close_cog($(this))
      })
  })
})

function close_cog(selector) {
  $(selector).closest('.message-dropdown').remove()
}

export default MessageCog

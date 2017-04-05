import * as cc from "./chat_channel"
import * as utils from "./utils"
import Messages from "./messages"

class MessageCog {
  constructor() {
    this.register_events()
    this.original_text
  }
  close_cog(selector) {
    $(selector).closest('.message-dropdown').remove()
  }

  cancel_editing() {
    let input = $('.input-message')
    input.val(this.original_text)
    input.removeClass('editing')
    $('.input-message').val('')
    $('form.editing').removeClass('editing')
  }
  register_events() {
    $(document).ready(() => {
      $('body').on('click','.messages-box i.message-cog', e => {
        let id = $(e.currentTarget).closest('li.message').attr('id')
        // console.log('message cog clicked...', id)
        cc.push('message_cog:open', {message_id: id})
          .receive("ok", resp => {
            $(`#${id} .message-cog-container`).append(resp.html)
          })
      })
      $('body').on('click','.flex-tab-container i.message-cog', e =>  {
        let id = $(e.currentTarget).closest('li').attr('id')
        let target = $(e.currentTarget)

        cc.push('message_cog:open', {message_id: id, flex_tab: true})
          .receive("ok", resp => {
            target.closest('.message-cog-container').append(resp.html)
          })
      })
      .on('click', '.message-dropdown-close', e => {
        this.close_cog($(e.currentTarget))
      })
      .on('keydown', '.input-message.editing', e => {
        if (e.keyCode === 13 && !e.shiftKey) {
          $('form.editing').removeClass('editing')
        }
      })
      .on('keyup', '.input-message.editing', e => {
        if (e.keyCode == 27)
          this.cancel_editing()
      })
      .on('click', '.editing-commands-cancel', e => {
        this.cancel_editing()
      })
      .on('click', '.editing-commands-save', e => {
        $('.input-message').removeClass('editing')
        $('form.editing').removeClass('editing')
        Messages.send_message($('.message-form-text').val())
      })
      .on('click', '.messages-box .message-action', e => {
        let ct = e.currentTarget
        let data_id = $(ct).attr('data-id')
        let message_id = $(ct).closest('li.message').attr('id')
        let input = $('.input-message')
        if (data_id == "edit-message") {
          cc.push('message:get-body:' + message_id)
            .receive("ok", resp => {
              console.log('body', resp.body)
              input.addClass('editing').val(resp.body)
              input.closest('form').addClass('editing')
              input.autogrow()
              this.original_text = resp.body
              $('#' + message_id).addClass('editing')
              this.close_cog($(ct))
            })
        } else if (data_id == "reaction-message") {
          console.log('clicked reaction-message', $(ct))
          chat_emoji.open_reactions(ct, message_id)

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
                $(resp.selector).find('pre code').each(function(i, block) {
                  hljs.highlightBlock(block);
                });
              }
              this.close_cog($(ct))
            })
        }
      })
    })
  }
}

export default MessageCog

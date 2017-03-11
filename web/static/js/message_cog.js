import * as cc from "./chat_channel"
import * as utils from "./utils"

class MessageCog {
  constructor() {
    this.register_events()
    this.has_more = false
    this.has_more_next = false
  }
  close_cog(selector) {
    $(selector).closest('.message-dropdown').remove()
  }
  update_state(resp) {
    this.has_more = resp.has_more
    this.has_more_next = resp.has_more_next
  }
  register_events() {
    $(document).ready(() => {
      $('body').on('click','.messages-box i.message-cog', e => {
        let id = $(this).closest('li.message').attr('id')
        console.log('message cog clicked...', id)
        cc.push('message_cog:open', {message_id: id})
          .receive("ok", resp => {
            $(e.currentTarget).parent().append(resp.html)
          })
      })
      .on('click','.flex-tab-container i.message-cog', e =>  {
        let id = $(e.currentTarget).closest('li').attr('id')
        // let ts = $(this).closest('li').data('timestamp')
        console.log('flex cog clicked...', id)
        cc.push('message_cog:open', {message_id: id, flex_tab: true})
          .receive("ok", resp => {
            $(e.currentTarget).parent().append(resp.html)
          })
      })
      .on('click', 'li.jump-to-message', e => {
        e.preventDefault()
        let ct = e.currentTarget
        console.log('....', $(ct).closest('li.message'))
        let ts = $(ct).closest('li.message').data('timestamp')
        console.warn('ts', ts)
        let target = $('.messages-box li[data-timestamp="' + ts + '"]')
        if (target.offset()) {
          console.log("jump-to found an offset")
          scroll_to(target, -400)
          this.close_cog($(ct))
        } else {
          console.log("jump-to need to load some messages")
          utils.page_loading()
          $('.messages-box .wrapper ul li.load-more').html(utils.loading_animation())
          cc.get('/messages/surrounding', {timestamp: ts})
            .receive("ok", resp => {
              $('.messages-box .wrapper ul')[0].innerHTML = resp.html
              let pos_elem = $(`.messages-box li[data-timestamp="${ts}"]`).attr('id')
              scroll_to($('#' + pos_elem), -200)
              if (resp.has_more_next) {
                $('.jump-recent').removeClass('not')
                $('.messages-box .wrapper ul').append(utils.loadmore())
              }
              utils.remove_page_loading()
              this.close_cog($(ct))
              this.update_state(resp)
            })
        }
        return false
      })
      .on('click', '.message-dropdown-close', e => {
        this.close_cog($(e.currentTarget))
      })
      .on('click', '.jump-recent', e => {
        utils.page_loading()
        $('.messages-box .wrapper ul li.load-more').html(utils.loading_animation())
        cc.get('/messages/last')
          .receive("ok", resp => {
            $('.messages-box .wrapper ul')[0].innerHTML = resp.html
            utils.remove_page_loading()
            utils.scroll_bottom()
            this.close_cog($(e.currentTarget))
            this.update_state(resp)
          })
      })
      .on('click', '.messages-box .message-action', e => {
        let ct = e.currentTarget
        let data_id = $(ct).attr('data-id')
        let message_id = $(ct).closest('li.message').attr('id')
        if (data_id == "edit-message") {
          cc.push('message:get-body:' + message_id)
            .receive("ok", resp => {
              $('textarea.input-message').text(resp.body).addClass('editing')
              $('#' + message_id).addClass('editing')
              this.close_cog($(ct))
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
              this.close_cog($(ct))
            })
        }
      })
    })
  }
}

export default MessageCog

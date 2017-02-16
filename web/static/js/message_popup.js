import * as cc from './chat_channel'
import * as utils from './utils'

const popup_window = '.message-popup-results';

class MessagePopup {

  constructor() {
    this.open = undefined;
  }

  close_popup() {
    $(popup_window).html('')
  }

  handle_enter() {
    if (this.open) {
      let selected = $('.popup-item.selected')
      if (selected.length == 1) {
        this.select_item(selected)
      }
      this.close_popup()
    }
  }

  open_users() {
    this.open = "users";
    cc.push('message_popup:open:users')
      .receive("ok", resp => {
        console.log('message_popup:open:users', resp)
        $(popup_window).html(resp.html)
          $('.popup-item').hover(
            function() {
              $('.popup-item.selected').removeClass('selected')
              $(this).addClass('selected') //.attr('style', 'color: white;')
            },
            function() {
              // $(this).removeClass('selected') //.attr('style', 'color: rgb(160,160.160);')
            });
          $('.popup-item').click(function() {
            message_popup.select_item($(this))
            message_popup.close_popup()
            $('textarea.message-form-text').focus()
          })
      })
  }

  register_user_input() {
    $('body').on('user:input', msg => {
      if (this.open) {
        console.log('popup open', msg.keyCode, this.open)
      } else {
        console.log('no popup open', msg.keyCode)
        if (msg.keyCode == 64) {
          this.open_users()
        }
      }
    })
  }

  select_item(elem) {
    let txt = $('.message-form-text').val()
    $('.message-form-text').val(txt + elem.attr('data-name') + ' ')
  }

}

window.message_popup = new MessagePopup();
message_popup.register_user_input();

export default MessagePopup

// $(document).ready(function() {
  // $('.popup-item').hover(
  //   function() {
  //     console.log('popup focus')
  //     $(this).addClass('selected')
  //   },
  //   function() {
  //     console.log('popup blur')
  //     $(this).removeClass('selected')
  //   }
  // );
  // $('body').on('focus', '.popup-item', function() {
  //   console.log('popup focus')
  //   $(this).addClass('selected')
  // })
  // $('body').on('blur', '.popup-item', function() {
  //   console.log('popup blur')
  //   $(this).removeClass('selected')
  // })
// })


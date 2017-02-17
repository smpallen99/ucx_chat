import * as cc from './chat_channel'
import * as utils from './utils'

const debug = false;

const popup_window = '.message-popup-results';
const item = '.popup-item';
const selected = item + '.selected';
const form_text = 'textarea.message-form-text';

class MessagePopup {

  constructor() {
    this.open = undefined;
    this.pattern = [];
  }

  close_popup() {
    $(popup_window).html('')
    this.set_focus()
    this.open = undefined
    this.pattern = []
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

  handle_key(keyCode) {
    this.pattern.push(keyCode)
    cc.push('message_popup:get:users', {pattern: this.pattern})
      .receive("ok", resp => {
        if (resp.close) {
          this.close_popup()
        } else {
          this.handle_channel_resp(resp)
        }
    })
  }

  handle_up_arrow_key() {
    let prev = $(selected).prev()
    $(selected).removeClass('selected')

    if (prev.length > 0) {
      prev.addClass('selected')
    } else {
      $(item).last().addClass('selected')
    }
    return false
  }

  handle_down_arrow_key() {
    let next = $(selected).next()
    $(selected).removeClass('selected')

    if (next.length > 0) {
      next.addClass('selected')
    } else {
      $(item).first().addClass('selected')
    }
    return false
  }
  handle_bs_key() {
    if (debug) { console.log('BS') }
    if ($(form_text).val().slice(-1) != "@") {
      this.pattern.pop()
      cc.push('message_popup:get:users', {pattern: this.pattern})
        .receive("ok", resp => {
          if (resp.close) {
            this.close_popup()
          } else {
            this.handle_channel_resp(resp)
          }
      })
    } else {
      this.close_popup()
    }
    return true
  }

  handle_bs_key_not_open() {
    let match = $(form_text).val().match(/(^|\s)@([^\s]*)$/)
    if (match) {
      let string = match[match.length - 1].slice(0, -1)
      let pattern = []
      for(var i = 0; i < string.length; i++) { pattern.push(string.charCodeAt(i)) }
      cc.push('message_popup:get:users', {pattern: pattern})
        .receive("ok", resp => {
          if (debug) { console.log('bs not open resp', pattern, resp) }
          if (!resp.close) {
            this.pattern = pattern
            this.open = "users"
            this.handle_channel_resp(resp)
          }
        })
    }
    return true
  }

  handle_tab_key() {
    this.select_item($(selected))
    this.close_popup()
    return false
  }

  open_users(pattern=[]) {
    this.open = "users";
    cc.push('message_popup:get:users', {pattern: pattern})
      .receive("ok", resp => {
        this.handle_channel_resp(resp)
    })
  }

  handle_channel_resp(resp) {
    $(popup_window).html(resp.html)
      $('.popup-item').hover(
        function() {
          $('.popup-item.selected').removeClass('selected')
          $(this).addClass('selected')
        },
        function() {
          // $(this).removeClass('selected') //.attr('style', 'color: rgb(160,160.160);')
        });
      $('.popup-item').click(function() {
        message_popup.select_item($(this))
        message_popup.close_popup()
      })
  }

  set_focus() {
    $(form_text).focus()
  }

  register_user_input() {
    $('body').on('user:input', msg => {
      if (this.open) {
        switch(msg.keyCode) {
          case 38: // up arrow
            return this.handle_up_arrow_key()
          case 40: // down arrow
            return this.handle_down_arrow_key()
          case 8:  // BS
            return this.handle_bs_key()
          case 9:  // TAB
            return this.handle_tab_key()
          default:
            return this.handle_key(msg.keyCode)
        }
      } else {
        if (msg.keyCode == 64) {
          // if (debug) { console.log('found @', "'" + $(form_text).val() + "'") }
          let prev = $(form_text).val().slice(-1);
          if (prev == "" || prev == " ") {
            this.open_users()
          }
        } else if (msg.keyCode == 8) { // BS
          return this.handle_bs_key_not_open()
        }
      }
    })
  }

  select_item(elem) {
    let text = $('.message-form-text').val()
    let new_text = text.replace(/(.*)@(.*$)/, "$1@" + elem.attr('data-name') + ' ')
    $('.message-form-text').val(new_text)
  }

}

window.message_popup = new MessagePopup();
message_popup.register_user_input();

export default MessagePopup
